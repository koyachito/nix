--- Preview office documents (Word/Excel/PowerPoint, OpenDocument) by letting
--- LibreOffice convert them to PDF once, then rendering pages with `pdftoppm`
--- the same way Yazi's built-in PDF previewer does.
---
--- The intermediate PDF is keyed by path + mtime + size and kept next to
--- Yazi's image cache, so flipping through pages only pays for the conversion
--- on the first page.

local M = {}

-- Where the converted PDF for `job`'s file lives, plus the directory holding it.
local function pdf_dir(job, cache)
	local cha = fs.cha(job.file.url)
	local key = ya.hash(string.format(
		"office//%s//%s//%s",
		tostring(job.file.url),
		tostring(cha and cha.mtime),
		tostring(cha and cha.len)
	))
	return cache.parent:join("office-" .. key)
end

-- Returns the Url of the converted PDF, or nil plus an error.
local function convert(job, cache)
	local dir = pdf_dir(job, cache)

	local outs = fs.read_dir(dir, { limit = 1 })
	if outs and outs[1] then
		return outs[1].url
	end

	local ok, err = fs.create("dir_all", dir)
	if not ok then
		return nil, Err("Failed to create `%s`, error: %s", dir, err)
	end

	-- Tell the user something is happening; conversion takes a few seconds.
	ya.preview_widget(
		job,
		ui.Text(ui.Line("Converting with LibreOffice..."):reverse()):area(job.area):wrap(ui.Wrap.YES)
	)

	-- A private user profile, so this never fights a running LibreOffice GUI
	-- over the lock in ~/.config/libreoffice.
	local profile = cache.parent:join("office-profile")

	-- stylua: ignore
	local output, err = Command("soffice")
		:arg({
			"-env:UserInstallation=file://" .. tostring(profile),
			"--headless", "--norestore", "--nolockcheck", "--nodefault", "--nologo",
			"--convert-to", "pdf",
			"--outdir", tostring(dir),
			tostring(job.file.path),
		})
		:output()

	if not output then
		return nil, Err("Failed to start `soffice`, error: %s", err)
	elseif not output.status.success then
		return nil, Err("`soffice` exited with error code %s, stderr: %s", output.status.code, output.stderr)
	end

	outs = fs.read_dir(dir, { limit = 1 })
	if not outs or not outs[1] then
		return nil, Err("`soffice` produced no PDF, stdout: %s", output.stdout)
	end
	return outs[1].url
end

function M:peek(job)
	local start, cache = os.clock(), ya.file_cache(job)
	if not cache then
		return
	end

	local ok, err, bound = self:preload(job)
	if bound and bound > 0 then
		return ya.emit("peek", { bound - 1, only_if = job.file.url, upper_bound = true })
	elseif not ok or err then
		return ya.preview_widget(job, err)
	end

	ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))
	local _, err = ya.image_show(cache, job.area)
	ya.preview_widget(job, err)
end

function M:seek(job)
	local h = cx.active.current.hovered
	if h and h.url == job.file.url then
		local step = ya.clamp(-1, job.units, 1)
		ya.emit("peek", { math.max(0, cx.active.preview.skip + step), only_if = job.file.url })
	end
end

function M:preload(job)
	local cache = ya.file_cache(job)
	if not cache or fs.cha(cache) then
		return true
	end

	local pdf, err = convert(job, cache)
	if not pdf then
		return true, err
	end

	-- stylua: ignore
	local output, err = Command("pdftoppm")
		:arg({
			"-f", job.skip + 1,
			"-l", job.skip + 1,
			"-singlefile",
			"-jpeg", "-jpegopt", "quality=" .. rt.preview.image_quality,
			tostring(pdf), tostring(cache),
		})
		:output()

	if not output then
		return true, Err("Failed to start `pdftoppm`, error: %s", err)
	elseif not output.status.success then
		local pages = job.skip > 0 and tonumber(output.stderr:match("the last page %((%d+)%)"))
		return true, Err("Failed to convert PDF to image, stderr: %s", output.stderr), pages
	end

	return ya.image_precache(Url(cache .. ".jpg"), cache)
end

function M:spot(job) require("file"):spot(job) end

return M
