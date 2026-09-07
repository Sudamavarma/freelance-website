# High-Performance HTTP Web Server in PowerShell with full HTML5 Video Range Streaming support
$port = 8080
$path = $PSScriptRoot
if (-not $path) { $path = (Get-Location).Path }

while ($true) {
    try {
        $listener = New-Object System.Net.HttpListener
        $prefix = "http://localhost:$port/"
        $listener.Prefixes.Add($prefix)
        $listener.Start()
        Write-Output "HTTP server successfully started at: $prefix"
        Write-Output "Serving files from: $path"
        break
    } catch {
        $port++
        if ($port -gt 8100) {
            Write-Error "Could not bind to any port in range 8080-8100"
            exit 1
        }
    }
}

$mimeTypes = @{
    ".html" = "text/html; charset=utf-8";
    ".htm"  = "text/html; charset=utf-8";
    ".css"  = "text/css; charset=utf-8";
    ".js"   = "application/javascript; charset=utf-8";
    ".json" = "application/json; charset=utf-8";
    ".png"  = "image/png";
    ".jpg"  = "image/jpeg";
    ".jpeg" = "image/jpeg";
    ".gif"  = "image/gif";
    ".svg"  = "image/svg+xml";
    ".webp" = "image/webp";
    ".ico"  = "image/x-icon";
    ".mp4"  = "video/mp4";
    ".webm" = "video/webm";
    ".mov"  = "video/quicktime";
    ".woff2"= "font/woff2";
    ".woff" = "font/woff";
    ".ttf"  = "font/ttf"
}

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        try {
            $rawUrl = $request.RawUrl.Split('?')[0].Split('#')[0]
            if ($rawUrl -eq "/" -or [string]::IsNullOrWhiteSpace($rawUrl)) {
                $reqPath = "index.html"
            } else {
                $reqPath = $rawUrl.TrimStart('/')
            }

            $reqPath = [System.Uri]::UnescapeDataString($reqPath)
            $filePath = Join-Path $path $reqPath
            $fullPath = [System.IO.Path]::GetFullPath($filePath)
            $rootPath = [System.IO.Path]::GetFullPath($path)

            # Security check
            if (-not $fullPath.StartsWith($rootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
                $response.StatusCode = 403
                $bytes = [System.Text.Encoding]::UTF8.GetBytes("403 Forbidden")
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
                $response.Close()
                continue
            }

            # Check if file exists, or check .mp4.mp4 fallback
            $targetFile = $null
            if (Test-Path -Path $fullPath -PathType Leaf) {
                $targetFile = $fullPath
            } elseif (Test-Path -Path ($fullPath + ".mp4") -PathType Leaf) {
                $targetFile = $fullPath + ".mp4"
            }

            if ($targetFile) {
                $ext = [System.IO.Path]::GetExtension($targetFile).ToLower()
                $mime = $mimeTypes[$ext]
                if (-not $mime) { $mime = "application/octet-stream" }

                $fileInfo = New-Object System.IO.FileInfo($targetFile)
                $fileLength = $fileInfo.Length

                $response.ContentType = $mime
                $response.Headers.Add("Access-Control-Allow-Origin", "*")
                $response.Headers.Add("Accept-Ranges", "bytes")

                $rangeHeader = $request.Headers["Range"]

                if ($request.HttpMethod -eq "HEAD") {
                    $response.StatusCode = 200
                    $response.ContentLength64 = $fileLength
                    $response.Close()
                    continue
                }

                if ($rangeHeader -and $rangeHeader.StartsWith("bytes=")) {
                    # Handle HTTP 206 Partial Content
                    $range = $rangeHeader.Substring(6).Split('-')
                    [long]$start = 0
                    [long]$end = $fileLength - 1

                    if (-not [string]::IsNullOrEmpty($range[0])) {
                        $start = [int64]::Parse($range[0])
                    }
                    if ($range.Length -gt 1 -and -not [string]::IsNullOrEmpty($range[1])) {
                        $end = [int64]::Parse($range[1])
                    }

                    if ($end -ge $fileLength) { $end = $fileLength - 1 }
                    $length = $end - $start + 1

                    if ($start -ge $fileLength -or $start -gt $end) {
                        $response.StatusCode = 416 # Range Not Satisfiable
                        $response.Headers.Add("Content-Range", "bytes */$fileLength")
                        $response.Close()
                        continue
                    }

                    $response.StatusCode = 206
                    $response.Headers.Add("Content-Range", "bytes $start-$end/$fileLength")
                    $response.ContentLength64 = $length

                    $fileStream = [System.IO.File]::OpenRead($targetFile)
                    try {
                        $fileStream.Seek($start, [System.IO.SeekOrigin]::Begin) | Out-Null
                        $buffer = New-Object byte[] 65536
                        [long]$bytesRemaining = $length
                        while ($bytesRemaining -gt 0) {
                            $toRead = [Math]::Min($buffer.Length, $bytesRemaining)
                            $bytesRead = $fileStream.Read($buffer, 0, $toRead)
                            if ($bytesRead -le 0) { break }
                            $response.OutputStream.Write($buffer, 0, $bytesRead)
                            $bytesRemaining -= $bytesRead
                        }
                    } finally {
                        $fileStream.Close()
                        $fileStream.Dispose()
                    }
                } else {
                    # Standard 200 OK
                    $response.StatusCode = 200
                    $response.ContentLength64 = $fileLength
                    $fileStream = [System.IO.File]::OpenRead($targetFile)
                    try {
                        $buffer = New-Object byte[] 65536
                        while ($true) {
                            $bytesRead = $fileStream.Read($buffer, 0, $buffer.Length)
                            if ($bytesRead -le 0) { break }
                            $response.OutputStream.Write($buffer, 0, $bytesRead)
                        }
                    } finally {
                        $fileStream.Close()
                        $fileStream.Dispose()
                    }
                }
            } else {
                # 404
                $response.StatusCode = 404
                $bytes = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            }
        } catch {
            # Client aborted or stream closed prematurely (normal during video scrubbing)
        } finally {
            try { $response.Close() } catch {}
        }
    }
} finally {
    if ($listener -and $listener.IsListening) {
        $listener.Stop()
        $listener.Close()
    }
}
