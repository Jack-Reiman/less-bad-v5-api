# Complete generator script for PROS-styled VEXcode V5 C++ Documentation

$ErrorActionPreference = "Stop"

. .\build_data.ps1

function Get-RelativeRoot($destPath) {
    if ($destPath.StartsWith("api/cpp/")) {
        return "../../"
    } else {
        return "./"
    }
}

function Clean-HtmlContent($raw) {
    if (-not $raw) { return "" }
    $s = $raw -replace 'https?://web\.archive\.org/web/\d+[^/]*/https://api\.vex\.com/v5/home/cpp/Enums\.html', 'enums.html'
    $s = $s -replace 'https?://web\.archive\.org/web/\d+[^/]*/https://api\.vex\.com/v5/home/cpp/Brain/Brain\.Screen\.html', 'brain_screen.html'
    $s = $s -replace 'https?://web\.archive\.org/web/\d+[^/]*/https://api\.vex\.com/v5/home/cpp/Brain/Brain\.Battery\.html', 'brain_battery.html'
    $s = $s -replace 'https?://web\.archive\.org/web/\d+[^/]*/https://api\.vex\.com/v5/home/cpp/Brain/Brain\.SDcard\.html', 'brain_sdcard.html'
    $s = $s -replace 'https?://web\.archive\.org/web/\d+[^/]*/https://api\.vex\.com/v5/home/cpp/Brain/Timer\.html', 'timer.html'
    $s = $s -replace 'https?://web\.archive\.org/web/\d+[^/]*/https://api\.vex\.com/v5/home/cpp/Controller/Controller\.Axis\.html', 'controller_axis.html'
    $s = $s -replace 'https?://web\.archive\.org/web/\d+[^/]*/https://api\.vex\.com/v5/home/cpp/Controller/Controller\.Button\.html', 'controller_button.html'
    $s = $s -replace 'https?://web\.archive\.org/web/\d+[^/]*/https://api\.vex\.com/v5/home/cpp/Controller/Controller\.Screen\.html', 'controller_screen.html'
    $s = $s -replace 'https?://web\.archive\.org/web/\d+[^/]*/https://api\.vex\.com/v5/home/cpp/Color\.html', 'color.html'
    $s = $s -replace 'https?://web\.archive\.org/web/\d+[^/]*/https://api\.vex\.com/v5/home/cpp/([A-Za-z0-9_]+)\.html', '$1.html'
    $s = $s -replace 'Brain/Brain\.Screen\.html', 'brain_screen.html'
    $s = $s -replace 'Brain/Brain\.Battery\.html', 'brain_battery.html'
    $s = $s -replace 'Brain/Brain\.SDcard\.html', 'brain_sdcard.html'
    $s = $s -replace 'Brain/Timer\.html', 'timer.html'
    $s = $s -replace 'brain_timer\.html', 'timer.html'
    $s = $s -replace 'Controller/Controller\.Axis\.html', 'controller_axis.html'
    $s = $s -replace 'Controller/Controller\.Button\.html', 'controller_button.html'
    $s = $s -replace 'Controller/Controller\.Screen\.html', 'controller_screen.html'
    $s = $s -replace 'Color\.html', 'color.html'
    $s = $s -replace 'Enums\.html', 'enums.html'
    $s = $s -replace 'Motor\.html', 'motor.html'
    $s = $s -replace 'Motor55\.html', 'motor55.html'
    $s = $s -replace 'MotorGroup\.html', 'motorgroup.html'
    $s = $s -replace 'Drivetrain\.html', 'drivetrain.html'
    $s = $s -replace 'SmartDrive\.html', 'smartdrive.html'
    $s = $s -replace 'Inertial\.html', 'inertial.html'
    $s = $s -replace 'Optical\.html', 'optical.html'
    $s = $s -replace 'Distance\.html', 'distance.html'
    $s = $s -replace 'Rotation\.html', 'rotation.html'
    $s = $s -replace 'GPS\.html', 'gps.html'
    $s = $s -replace 'AiVision\.html', 'aivision.html'
    $s = $s -replace 'Vision\.html', 'vision.html'
    $s = $s -replace 'Pneumatics\.html', 'pneumatics.html'
    $s = $s -replace 'Triport\.html', 'triport.html'
    $s = $s -replace 'Bumper\.html', 'bumper.html'
    $s = $s -replace 'Limit\.html', 'limit.html'
    $s = $s -replace 'Line\.html', 'line.html'
    $s = $s -replace 'Encoder\.html', 'encoder.html'
    $s = $s -replace 'Potentiometer\.html', 'potentiometer.html'
    $s = $s -replace 'PotentiometerV2\.html', 'potentiometer_v2.html'
    $s = $s -replace 'Competition\.html', 'competition.html'
    $s = $s -replace 'Thread\.html', 'thread.html'
    $s = $s -replace 'Event\.html', 'event.html'
    $s = $s -replace 'Timer\.html', 'timer.html'
    $s = $s -replace 'DigitalOut\.html', 'digital_out.html'
    $s = $s -replace 'DigitalIn\.html', 'digital_in.html'
    $s = $s -replace 'AnalogIn\.html', 'analog_in.html'
    $s = $s -replace 'LED\.html', 'led.html'
    return $s
}

function Format-CppPrototype($className, $methodName, $rawArgs, $returnsText, $tableHtml) {
    $bareClass = $className -replace '^.*::', ''
    $cleanMethod = $methodName -replace '^(?:vex::)?[A-Za-z0-9_]+::', ''
    $isCtor = ($bareClass -eq $cleanMethod -or $cleanMethod -match 'Constructor$' -or $methodName -eq $className)
    
    if (-not $rawArgs -or $rawArgs.Trim() -eq "") {
        if ($isCtor) {
            return "$bareClass();"
        }
        $ret = if ($returnsText -match '^(?:None|void)') { "void" } 
               elseif ($returnsText -match 'double') { "double" } 
               elseif ($returnsText -match 'bool') { "bool" } 
               elseif ($returnsText -match 'int') { "int32_t" } 
               elseif ($returnsText -match 'color') { "vex::color" } 
               elseif ($returnsText -match 'directionType') { "vex::directionType" } 
               else { "void" }
        return "$ret $bareClass`::$cleanMethod();"
    }

    $argTokens = $rawArgs -split ',' | ForEach-Object { $_.Trim() }
    $typedArgs = @()

    foreach ($a in $argTokens) {
        if ([string]::IsNullOrWhiteSpace($a)) { continue }

        # Check if already typed, e.g. "int32_t index", "bool reverse", "gearSetting gears"
        if ($a -match '^(?:const\s+)?([A-Za-z0-9_:]+(?:<[^>]+>)?[\*&]?)\s+([A-Za-z0-9_]+)(?:\s*=\s*(.+))?$') {
            $t = $matches[1]
            $n = $matches[2]
            $def = if ($matches[3]) { " = " + $matches[3] } else { "" }
            $typedArgs += "$t $n$def"
            continue
        }

        $cleanArg = $a -replace '[^A-Za-z0-9_]', ''
        if ([string]::IsNullOrWhiteSpace($cleanArg)) { continue }
        
        switch -Regex ($cleanArg) {
            '^(direction|dir)$' { $typedArgs += "vex::directionType $cleanArg" }
            '^(velocity|vel|speed)$' { $typedArgs += "double $cleanArg" }
            '^(units_v|velocityUnits)$' { $typedArgs += "vex::velocityUnits $cleanArg = vex::velocityUnits::rpm" }
            '^(rotation|rot|distance|dist|deg|degrees|angle|timeout)$' { $typedArgs += "double $cleanArg" }
            '^(units|rotationUnits)$' { 
                if ($cleanMethod -match '^(drive|distance|objectDistance)') {
                    $typedArgs += "vex::distanceUnits $cleanArg = vex::distanceUnits::mm"
                } elseif ($cleanMethod -match '^(timer|wait|timeout)') {
                    $typedArgs += "vex::timeUnits $cleanArg = vex::timeUnits::msec"
                } else {
                    $typedArgs += "vex::rotationUnits $cleanArg = vex::rotationUnits::deg"
                }
            }
            '^(distanceUnits)$' { $typedArgs += "vex::distanceUnits $cleanArg = vex::distanceUnits::mm" }
            '^(timeUnits)$' { $typedArgs += "vex::timeUnits $cleanArg = vex::timeUnits::msec" }
            '^(percentUnits)$' { $typedArgs += "vex::percentUnits $cleanArg = vex::percentUnits::pct" }
            '^(voltageUnits)$' { $typedArgs += "vex::voltageUnits $cleanArg = vex::voltageUnits::volt" }
            '^(wait)$' { $typedArgs += "bool $cleanArg = true" }
            '^(reverse|reversed)$' { $typedArgs += "bool $cleanArg = false" }
            '^(port|index|channel|pin|port[12AB])$' { 
                if ($className -match '^(?:vex::)?(pneumatics|bumper|limit|line|encoder|potentiometer|potentiometerV2|digital_out|digital_in|analog_in|led)$') {
                    $typedArgs += "vex::triport::port &$cleanArg"
                } else {
                    $typedArgs += "int32_t $cleanArg"
                }
            }
            '^(value|state)$' {
                if ($className -match '^(?:vex::)?(pneumatics|digital_out)$' -or $tableHtml -match "\b$cleanArg\b.*?bool") {
                    $typedArgs += "bool $cleanArg"
                } else {
                    $typedArgs += "double $cleanArg"
                }
            }
            '^(mode)$' { $typedArgs += "vex::brakeType $cleanArg" }
            '^(callback|func)$' { $typedArgs += "void (*$cleanArg)(void)" }
            default {
                if ($tableHtml -match "\b$cleanArg\b.*?bool") {
                    $typedArgs += "bool $cleanArg"
                } elseif ($tableHtml -match "\b$cleanArg\b.*?(?:int|integer|port)") {
                    $typedArgs += "int32_t $cleanArg"
                } elseif ($tableHtml -match "\b$cleanArg\b.*?(?:double|float|number)") {
                    $typedArgs += "double $cleanArg"
                } else {
                    $typedArgs += "auto $cleanArg"
                }
            }
        }
    }

    $argsStr = $typedArgs -join ", "

    if ($isCtor) {
        return "$bareClass( $argsStr );"
    }

    $ret = if ($returnsText -match '^(?:None|void)') { "void" } 
           elseif ($returnsText -match 'double') { "double" } 
           elseif ($returnsText -match 'bool') { "bool" } 
           elseif ($returnsText -match 'int') { "int32_t" } 
           elseif ($returnsText -match 'color') { "vex::color" } 
           elseif ($returnsText -match 'directionType') { "vex::directionType" } 
           else { "void" }

    return "$ret $bareClass`::$cleanMethod( $argsStr );"
}

function Format-PygmentsCpp([string]$rawCode) {
    if ([string]::IsNullOrWhiteSpace($rawCode)) { return "<span></span>" }
    
    $lines = $rawCode -split "`r?`n"
    $outLines = [System.Collections.Generic.List[string]]::new()
    
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        if ($trimmed.StartsWith("//")) {
            $enc = [System.Net.WebUtility]::HtmlEncode($line)
            $outLines.Add("<span class=`"c1`">$enc</span>")
            continue
        }
        
        $codePart = $line
        $commentPart = ""
        $cIdx = $line.IndexOf("//")
        if ($cIdx -ge 0) {
            $codePart = $line.Substring(0, $cIdx)
            $commentPart = "<span class=`"c1`">" + [System.Net.WebUtility]::HtmlEncode($line.Substring($cIdx)) + "</span>"
        }
        
        $pattern = '("(?:[^"\\]|\\.)*"|\b0x[0-9a-fA-F]+\b|\b\d+(?:\.\d+)?(?:f|u|l|ul)?\b|^\s*#\w+|::|->|\.|\+\+|--|<<|>>|<=|>=|==|!=|&&|\|\||[+\-*\/%=<>!&|^~?:,]|[(){}\[\];]|\w+|\s+|[^\s\w])'
        $matches = [regex]::Matches($codePart, $pattern)
        $lineHtml = [System.Text.StringBuilder]::new()
        
        foreach ($m in $matches) {
            $tok = $m.Value
            if ([string]::IsNullOrEmpty($tok)) { continue }
            
            if ($tok.StartsWith('"')) {
                $lineHtml.Append('<span class="s">' + [System.Net.WebUtility]::HtmlEncode($tok) + '</span>') | Out-Null
            } elseif ($tok.StartsWith('#')) {
                $lineHtml.Append('<span class="cp">' + [System.Net.WebUtility]::HtmlEncode($tok) + '</span>') | Out-Null
            } elseif ($tok -match '^(void|int|int8_t|int16_t|int32_t|int64_t|uint8_t|uint16_t|uint32_t|uint64_t|size_t|double|float|bool|char|auto|const|static|virtual|override|class|struct|enum|namespace|using|public|private|protected|true|false|nullptr|return|if|else|while|for|do|switch|case|break|continue|default|new|delete)$') {
                $lineHtml.Append("<span class=`"k`">$tok</span>") | Out-Null
            } elseif ($tok -match '^(vex|motor|motor_group|drivetrain|smartdrive|brain|controller|inertial|optical|distance|rotation|gps|aivision|vision|triport|bumper|limit|line|encoder|potentiometer|potentiometerV2|competition|thread|task|event|color|timer|pneumatics|brakeType|directionType|velocityUnits|rotationUnits|distanceUnits|timeUnits|percentUnits|voltageUnits|gearSetting|fontType|Brain|Controller|Axis|Button|Screen|SDcard|Battery)$') {
                $lineHtml.Append("<span class=`"nc`">$tok</span>") | Out-Null
            } elseif ($tok -match '^(0x[0-9a-fA-F]+|\d+(?:\.\d+)?(?:f|u|l|ul)?)$') {
                $lineHtml.Append("<span class=`"mi`">$tok</span>") | Out-Null
            } elseif ($tok -match '^(::|->|\.|\+\+|--|<<|>>|<=|>=|==|!=|&&|\|\||[+\-*\/%=<>!&|^~?])$') {
                $lineHtml.Append('<span class="o">' + [System.Net.WebUtility]::HtmlEncode($tok) + '</span>') | Out-Null
            } elseif ($tok -match '^[(){}\[\];,]$') {
                $lineHtml.Append("<span class=`"p`">$tok</span>") | Out-Null
            } elseif ($tok -match '^\s+$') {
                $lineHtml.Append($tok) | Out-Null
            } else {
                $lineHtml.Append('<span class="n">' + [System.Net.WebUtility]::HtmlEncode($tok) + '</span>') | Out-Null
            }
        }
        
        $outLines.Add($lineHtml.ToString() + $commentPart)
    }
    
    return "<span></span>" + ($outLines -join "`n")
}

function Build-Sidebar($activeDest, $sectionsByCat) {
    $rel = Get-RelativeRoot $activeDest

    $sb = @"
    <nav data-toggle="wy-nav-shift" class="wy-nav-side">
      <div class="wy-side-scroll">
        <div class="wy-side-nav-search">
          <a href="${rel}index.html" class="icon icon-home"> VEXcode V5 C++</a>
          <div class="version">
            vexcode v5 c++ api
          </div>
          <div role="search">
            <form id="rtd-search-form" class="wy-form" action="#" onsubmit="return false;">
              <input type="text" name="q" id="search-query-input" class="search-input" placeholder="Search docs" />
              <input type="hidden" name="check_keywords" value="yes" />
              <input type="hidden" name="area" value="default" />
            </form>
          </div>
        </div>
        <div class="wy-menu wy-menu-vertical" data-spy="affix" role="navigation" aria-label="main navigation">
"@

    foreach ($cat in $categories) {
        $isCatActive = $false
        foreach ($p in $cat.pages) {
            if ($p.dest -eq $activeDest) { $isCatActive = $true; break }
        }
        $ulClass = if ($isCatActive) { 'class="current"' } else { '' }

        $sb += @"
          <p class="caption"><span class="caption-text">$($cat.name)</span></p>
          <ul $ulClass>
"@
        foreach ($p in $cat.pages) {
            $isActive = ($p.dest -eq $activeDest)
            
            $link = if ($activeDest.StartsWith("api/cpp/")) {
                if ($p.dest.StartsWith("api/cpp/")) {
                    $p.dest.Substring("api/cpp/".Length)
                } else {
                    "../../" + $p.dest
                }
            } else {
                $p.dest
            }

            if ($isActive) {
                $sb += @"
            <li class="toctree-l1 current"><a class="reference internal current" href="#">$($p.title)</a>
"@
                if ($sectionsByCat -and $sectionsByCat.Count -gt 0) {
                    $sb += @"
              <ul>
"@
                    foreach ($catKey in $sectionsByCat.Keys) {
                        $items = $sectionsByCat[$catKey]
                        if ($items.Count -gt 0) {
                            $cId = $catKey.ToLower() -replace '[^a-z0-9]+', '-'
                            $sb += @"
                <li class="toctree-l2"><a class="reference internal" href="#$cId">$catKey</a></li>
"@
                        }
                    }
                    $sb += @"
              </ul>
"@
                }
                $sb += @"
            </li>
"@
            } else {
                $sb += @"
            <li class="toctree-l1"><a class="reference internal" href="$link">$($p.title)</a></li>
"@
            }
        }
        $sb += @"
          </ul>
"@
    }

    $sb += @"
        </div>
      </div>
    </nav>
"@
    return $sb
}

function Build-Breadcrumbs($activeDest, $pageTitle, $categoryName) {
    $rel = Get-RelativeRoot $activeDest
    $isHome = ($activeDest -eq "index.html")
    $isApiIndex = ($activeDest -eq "api/cpp/index.html")

    $sb = @"
<div role="navigation" aria-label="breadcrumbs navigation">
  <ul class="wy-breadcrumbs">
"@
    if ($isHome) {
        $sb += @"
    <li>Docs</li>
"@
    } else {
        $sb += @"
    <li><a href="${rel}index.html">Docs</a> &raquo;</li>
"@
    }
    if (-not $isHome -and $isApiIndex) {
        $sb += @"
    <li>API Home</li>
"@
    } elseif (-not $isHome -and -not $isApiIndex) {
        $sb += @"
    <li><a href="${rel}api/cpp/index.html">API Home</a> &raquo;</li>
    <li>$categoryName &raquo;</li>
    <li>$pageTitle C++ API</li>
"@
    }
    $sb += @"
    <li class="wy-breadcrumbs-aside">
      <a href="https://api.vex.com/v5/home/cpp/index.html" class="fa fa-external-link" target="_blank" rel="noopener"> Official VEX API</a>
    </li>
  </ul>
  <hr/>
</div>
"@
    return $sb
}

# Purge non-V5RC competition legal HTML files from api/cpp/
$legalDests = @()
foreach ($c in $categories) {
    foreach ($p in $c.pages) {
        if ($p.dest.StartsWith("api/cpp/")) {
            $legalDests += (Split-Path $p.dest -Leaf).ToLower()
        }
    }
}
if (Test-Path "api/cpp") {
    Get-ChildItem -Path "api/cpp" -Filter "*.html" | ForEach-Object {
        $nameLower = $_.Name.ToLower()
        if (-not ($legalDests -contains $nameLower) -and $nameLower -ne "index.html") {
            Write-Host "Purging non-V5RC legal file: $($_.Name)"
            Remove-Item $_.FullName -Force
        }
    }
}

# Global search index collector
$globalSearchIndex = @()


# Process each category and page
foreach ($cat in $categories) {
    foreach ($page in $cat.pages) {
        if ($page.isHome -or $page.isApiIndex) {
            continue
        }

        $source = $page.source
        $dest = $page.dest
        $pageTitle = $page.title
        $className = $page.className
        $portName = $page.port
        $summary = $page.summary
        $rel = Get-RelativeRoot $dest
        $catName = $cat.name

        Write-Host "Building $dest from $source..."

        $rawPath = Join-Path "raw_archive" $source
        if (-not (Test-Path $rawPath)) {
            Write-Host "ERROR: Missing $rawPath"
            continue
        }

        $html = Get-Content $rawPath -Raw

        # Add class itself to search index
        $globalSearchIndex += @{
            title = "$className ($pageTitle)"
            category = "$catName (Class Reference)"
            url = if ($dest.StartsWith("api/cpp/")) { $dest.Substring("api/cpp/".Length) } else { $dest }
            desc = $summary
        }

        # Handle Enums.html specifically
        if ($source -eq "Enums.html") {
            $secRegex = [regex]'(?s)<section id="([^"]+)">\s*<h[23]>(?:<a[^>]*>)?([^<]+)(?:</a>)?(?:<a[^>]*>#</a>)?</h[23]>(.*?)</section>'
            $enumSections = $secRegex.Matches($html)

            $enumHtmlBlocks = @()
            $tocItems = @()

            foreach ($es in $enumSections) {
                $eId = $es.Groups[1].Value
                $eTitle = $es.Groups[2].Value.Trim()
                $eBody = $es.Groups[3].Value

                $tocItems += "<li><a href='#$eId'>$eTitle</a></li>"

                # extract table
                $tMatch = [regex]::Match($eBody, '(?s)<table class="table">(.*?)</table>')
                $tHtml = ""
                if ($tMatch.Success) {
                    $rawTable = Clean-HtmlContent $tMatch.Groups[1].Value
                    $rowMatches = [regex]::Matches($rawTable, '(?s)<tr[^>]*>(.*?)</tr>')
                    $tRows = ""
                    $rIdx = 0
                    foreach ($rm in $rowMatches) {
                        $rowBody = $rm.Groups[1].Value
                        if ($rowBody -match '<th') { continue }
                        $rClass = if ($rIdx % 2 -eq 0) { "row-even" } else { "row-odd" }
                        $cleanRow = [regex]::Replace($rowBody, '(?s)<td[^>]*>(?:<p>)?(.*?)(?:</p>)?</td>', '<td>$1</td>')
                        $tRows += "<tr class=`"$rClass`">$cleanRow</tr>`n"
                        $rIdx++
                    }
                    $tHtml = @"
<table border="1" class="docutils">
  <colgroup>
    <col width="30%" />
    <col width="70%" />
  </colgroup>
  <thead valign="bottom">
    <tr class="row-odd"><th class="head">Constant / Value</th><th class="head">Description</th></tr>
  </thead>
  <tbody valign="top">
$tRows  </tbody>
</table>
"@
                }

                $enumHtmlBlocks += @"
<div class="section" id="$eId">
  <h3><a class="toc-backref" href="#toc-$eId">$eTitle</a><a class="headerlink" href="#$eId" title="Permalink to this headline"></a></h3>
  <p>Namespace: <code>vex::</code></p>
  $tHtml
</div>
<hr class="docutils" />
"@

                $globalSearchIndex += @{
                    title = "$eTitle (Enum)"
                    category = "Enumerated Types & Units"
                    url = "enums.html#$eId"
                    desc = "VEXcode enum constants for $eTitle"
                }
            }

            $pageContent = @"
<!DOCTYPE html>
<!--[if IE 8]><html class="no-js lt-ie9" lang="en" > <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en" > <!--<![endif]-->
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Enumerated Types &amp; Units Reference &mdash; VEXcode V5 C++ documentation</title>
  <link rel="stylesheet" href="${rel}assets/css/theme.css" type="text/css" />
  <link rel="stylesheet" href="${rel}assets/css/pygments.css" type="text/css" />
  <link rel="stylesheet" href="${rel}assets/css/tabs.css" type="text/css" />
  <link rel="stylesheet" href="${rel}assets/css/pros_extra.css" type="text/css" />
  <link rel="stylesheet" href="${rel}assets/css/pros_modern.css" type="text/css" />
</head>
<body class="wy-body-for-nav" role="document">
  <div class="wy-grid-for-nav">
$( Build-Sidebar $dest $null )
    <section data-toggle="wy-nav-shift" class="wy-nav-content-wrap">
      <nav class="wy-nav-top" role="navigation" aria-label="top navigation">
        <i data-toggle="wy-nav-top" class="fa fa-bars"></i>
        <a href="${rel}index.html">VEXcode V5 C++</a>
      </nav>
      <div class="wy-nav-content">
        <div class="rst-content">
$( Build-Breadcrumbs $dest "Enumerated Types & Units" "Reference" )
          <div role="main" class="document" itemscope="itemscope" itemtype="http://schema.org/Article">
            <div itemprop="articleBody">
              <div class="section" id="enumerated-types-and-units">
                <h1>Enumerated Types &amp; Units C++ Reference<a class="headerlink" href="#enumerated-types-and-units" title="Permalink to this headline"></a></h1>
                <div class="admonition note">
                  <p class="first admonition-title">Namespace Information</p>
                  <p class="last">All enumerated types in VEXcode C++ are defined in the <code>vex::</code> namespace. When using <code>using namespace vex;</code> in your program, the unqualified enum values (such as <code>coast</code>, <code>forward</code>, <code>rpm</code>, <code>degrees</code>, <code>msec</code>) can be used directly without prefix.</p>
                </div>
                
                <div class="contents local topic" id="contents">
                  <ul class="simple">
                    <li><a class="reference internal" href="#enumerations-list">Enumerations on this page</a>
                      <ul>
                        $( $tocItems -join "`n                        " )
                      </ul>
                    </li>
                  </ul>
                </div>

                <div class="section" id="enumerations-list">
                  $( $enumHtmlBlocks -join "`n" )
                </div>
              </div>
            </div>
          </div>
          <footer>
            <hr/>
            <div role="contentinfo">
              <p>&copy; Copyright 2024, VEX Robotics. V5RC Legal Components Reference.</p>
            </div>
          </footer>
        </div>
      </div>
    </section>
  </div>
  <script src="${rel}assets/js/sphinx_tabs.js"></script>
  <script src="${rel}assets/js/search_index.js"></script>
  <script src="${rel}assets/js/search.js"></script>
  <script src="${rel}assets/js/theme.js"></script>
  <script>
    document.addEventListener('DOMContentLoaded', () => {
      if (typeof initSearch === 'function' && typeof searchIndexData !== 'undefined') {
        initSearch(searchIndexData);
      }
    });
  </script>
</body>
</html>
"@
            $targetPath = Join-Path (Get-Location) $dest
            $parentDir = Split-Path $targetPath -Parent
            if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Force -Path $parentDir | Out-Null }
            $pageContent | Out-File -FilePath $targetPath -Encoding utf8
            continue
        }

        # Standard class pages
        $secRegex = [regex]'(?s)<section id="([^"]+)">\s*<h[23]>(?:<a[^>]*>)?([^<]+)(?:</a>)?(?:<a[^>]*>#</a>)?</h[23]>(.*?)</section>'
        $cleanHtml = $html -replace '(?s)<section id="(?:class-)?methods"[^>]*>\s*<h[23]>.*?</h[23]>', ''
        $secMatches = $secRegex.Matches($cleanHtml)

        $sectionsByCat = [ordered]@{
            "Constructor(s)" = @()
            "Movement Functions" = @()
            "Telemetry Functions" = @()
            "Configuration Functions" = @()
            "Functions" = @()
        }

        if ($dest -eq "api/cpp/pneumatics.html") {
            $pneumaticMethods = @(
                @{
                    cat = "Constructor(s)"
                    id = "initializing-the-pneumatics-class"
                    rawTitle = "Initializing the pneumatics Class"
                    cleanTitle = "pneumatics()"
                    desc = "<p>Creates a new <code>pneumatics</code> object connected to the specified 3-Wire (ADI) Port on the V5 Brain or a 3-Wire Expander.</p><p>This <code>Piston</code> object will be used in subsequent examples throughout this API documentation when referring to pneumatic class methods.</p>"
                    proto = "vex::pneumatics( vex::triport::port &port );"
                    example = @"
// Create the Brain.
brain Brain;

// Construct a Pneumatic Cylinder on 3-Wire Port A.
vex::pneumatics Piston = vex::pneumatics(Brain.ThreeWirePort.A);

// Alternatively, construct on a 3-Wire Expander on Smart Port 20:
vex::triport Expander = vex::triport(vex::PORT20);
vex::pneumatics Piston2 = vex::pneumatics(Expander.A);
"@
                    table = @"
<table border="1" class="docutils">
  <colgroup>
    <col width="22%" />
    <col width="78%" />
  </colgroup>
  <thead valign="bottom">
    <tr class="row-odd"><th class="head">Parameters</th><th class="head">&#160;</th></tr>
  </thead>
  <tbody valign="top">
    <tr class="row-even"><td><code>port</code></td><td>The 3-Wire Port that the pneumatic solenoid driver cable is connected to, whether on the Brain (e.g. <code>Brain.ThreeWirePort.A</code>) or on a 3-Wire Expander.</td></tr>
  </tbody>
</table>
"@
                    returns = ""
                    isWaiting = $false
                    isNonWaiting = $false
                },
                @{
                    cat = "Movement Functions"
                    id = "extend"
                    rawTitle = "extend()"
                    cleanTitle = "extend()"
                    desc = "<p>The <code>extend()</code> method actuates the pneumatic solenoid to extend the pneumatic cylinder by supplying 5V power.</p>"
                    proto = "void vex::pneumatics::extend();"
                    example = @"
// Extend the pneumatic cylinder.
Piston.extend();
"@
                    table = ""
                    returns = "None."
                    isWaiting = $false
                    isNonWaiting = $false
                },
                @{
                    cat = "Movement Functions"
                    id = "retract"
                    rawTitle = "retract()"
                    cleanTitle = "retract()"
                    desc = "<p>The <code>retract()</code> method de-actuates the pneumatic solenoid to retract the pneumatic cylinder by removing power.</p>"
                    proto = "void vex::pneumatics::retract();"
                    example = @"
// Retract the pneumatic cylinder.
Piston.retract();
"@
                    table = ""
                    returns = "None."
                    isWaiting = $false
                    isNonWaiting = $false
                },
                @{
                    cat = "Movement Functions"
                    id = "open"
                    rawTitle = "open()"
                    cleanTitle = "open()"
                    desc = "<p>The <code>open()</code> method opens the pneumatic cylinder. This is functionally identical to <code>extend()</code>.</p>"
                    proto = "void vex::pneumatics::open();"
                    example = @"
// Open the pneumatic claw mechanism.
Piston.open();
"@
                    table = ""
                    returns = "None."
                    isWaiting = $false
                    isNonWaiting = $false
                },
                @{
                    cat = "Movement Functions"
                    id = "close"
                    rawTitle = "close()"
                    cleanTitle = "close()"
                    desc = "<p>The <code>close()</code> method closes the pneumatic cylinder. This is functionally identical to <code>retract()</code>.</p>"
                    proto = "void vex::pneumatics::close();"
                    example = @"
// Close the pneumatic claw mechanism.
Piston.close();
"@
                    table = ""
                    returns = "None."
                    isWaiting = $false
                    isNonWaiting = $false
                },
                @{
                    cat = "Movement Functions"
                    id = "set"
                    rawTitle = "set()"
                    cleanTitle = "set()"
                    desc = "<p>The <code>set(value)</code> method sets the active state of the pneumatic solenoid. Passing <code>true</code> extends/opens the cylinder, and passing <code>false</code> retracts/closes the cylinder.</p>"
                    proto = "void vex::pneumatics::set( bool value );"
                    example = @"
// Extend while button L1 is held, retract when released.
if (Controller1.ButtonL1.pressing()) {
    Piston.set(true);
} else {
    Piston.set(false);
}
"@
                    table = @"
<table border="1" class="docutils">
  <colgroup>
    <col width="22%" />
    <col width="78%" />
  </colgroup>
  <thead valign="bottom">
    <tr class="row-odd"><th class="head">Parameters</th><th class="head">&#160;</th></tr>
  </thead>
  <tbody valign="top">
    <tr class="row-even"><td><code>value</code></td><td>Boolean state: <code>true</code> to extend / open the cylinder, <code>false</code> to retract / close the cylinder.</td></tr>
  </tbody>
</table>
"@
                    returns = "None."
                    isWaiting = $false
                    isNonWaiting = $false
                },
                @{
                    cat = "Movement Functions"
                    id = "toggle"
                    rawTitle = "toggle()"
                    cleanTitle = "toggle()"
                    desc = "<p>The <code>toggle()</code> method toggles the pneumatic cylinder between extended and retracted states.</p>"
                    proto = "void vex::pneumatics::toggle();"
                    example = @"
// Toggle the cylinder state when Button A is pressed.
Controller1.ButtonA.pressed([]() {
    Piston.toggle();
});
"@
                    table = ""
                    returns = "None."
                    isWaiting = $false
                    isNonWaiting = $false
                },
                @{
                    cat = "Telemetry Functions"
                    id = "value"
                    rawTitle = "value()"
                    cleanTitle = "value()"
                    desc = "<p>The <code>value()</code> method returns the current state of the pneumatic solenoid output.</p>"
                    proto = "int32_t vex::pneumatics::value();"
                    example = @"
// Display whether the cylinder is extended.
if (Piston.value()) {
    Brain.Screen.print(""Cylinder is Extended"");
} else {
    Brain.Screen.print(""Cylinder is Retracted"");
}
"@
                    table = ""
                    returns = "int32_t: 1 if the cylinder is currently extended/energized, 0 if retracted/de-energized."
                    isWaiting = $false
                    isNonWaiting = $false
                }
            )

            foreach ($pm in $pneumaticMethods) {
                $secObj = @{
                    id = $pm.id
                    rawTitle = $pm.rawTitle
                    cleanTitle = $pm.cleanTitle
                    desc = $pm.desc
                    proto = $pm.proto
                    example = $pm.example
                    table = $pm.table
                    returns = $pm.returns
                    isWaiting = $pm.isWaiting
                    isNonWaiting = $pm.isNonWaiting
                }
                $sectionsByCat[$pm.cat] += $secObj

                $fileUrl = if ($dest.StartsWith("api/cpp/")) { $dest.Substring("api/cpp/".Length) } else { $dest }
                $globalSearchIndex += @{
                    title = "vex::pneumatics::$($pm.cleanTitle)"
                    category = "Pneumatics C++ API"
                    url = "$fileUrl#$($pm.id)"
                    desc = ($pm.desc -replace '<[^>]+>', '')
                }
            }
        } else {
            foreach ($sm in $secMatches) {
            $secId = $sm.Groups[1].Value
            $secTitle = $sm.Groups[2].Value.Trim()
            $secBody = $sm.Groups[3].Value

            if ($secId -eq "class-methods" -or $secId -eq "methods") {
                continue
            }

            $cleanTitle = $secTitle -replace '^[A-Za-z0-9_]+\.', '' # e.g. Motor.spin() -> spin()
            $cleanTitleName = $cleanTitle -replace '\(.*', ''

            $isConstructor = ($secId -match 'constructor' -or $secId -match 'initializing')
            
            # Code example
            $codeMatch = [regex]::Match($secBody, '(?s)<code class="language-cpp">(.*?)</code>')
            $exampleCode = if ($codeMatch.Success) { 
                [System.Net.WebUtility]::HtmlDecode($codeMatch.Groups[1].Value.Trim())
            } else { "" }

            # Returns
            $retMatch = [regex]::Match($secBody, '(?s)<p><strong>Returns:</strong>\s*(.*?)</p>')
            $returnsText = if ($retMatch.Success) { Clean-HtmlContent $retMatch.Groups[1].Value.Trim() } else { "" }

            # Extract Table into PROS Docutils Table
            $tableMatch = [regex]::Match($secBody, '(?s)<table class="table">(.*?)</table>')
            $tableHtml = ""
            if ($tableMatch.Success) {
                $rawT = Clean-HtmlContent $tableMatch.Groups[1].Value
                $rowMatches = [regex]::Matches($rawT, '(?s)<tr[^>]*>(.*?)</tr>')
                $tRows = ""
                $rIdx = 0
                foreach ($rm in $rowMatches) {
                    $rowBody = $rm.Groups[1].Value
                    if ($rowBody -match '<th') { continue }
                    $rClass = if ($rIdx % 2 -eq 0) { "row-even" } else { "row-odd" }
                    $cleanRow = [regex]::Replace($rowBody, '(?s)<td[^>]*>(?:<p>)?(.*?)(?:</p>)?</td>', '<td>$1</td>')
                    $tRows += "<tr class=`"$rClass`">$cleanRow</tr>`n"
                    $rIdx++
                }
                if ($tRows -ne "") {
                    $tableHtml = @"
<table border="1" class="docutils">
  <colgroup>
    <col width="22%" />
    <col width="78%" />
  </colgroup>
  <thead valign="bottom">
    <tr class="row-odd"><th class="head">Parameters</th><th class="head">&#160;</th></tr>
  </thead>
  <tbody valign="top">
$tRows  </tbody>
</table>
"@
                }
            }

            # Body WITHOUT Table (prevents table cell <p> tags from leaking into description)
            $bodyWithoutTable = if ($tableMatch.Success) { $secBody.Replace($tableMatch.Value, '') } else { $secBody }

            # Description paragraphs and constructor parameter handling
            if ($isConstructor) {
                $ctorParams = [ordered]@{}
                $cleanDescParas = @()
                $pMatches = [regex]::Matches($bodyWithoutTable, '(?s)<p>(.*?)</p>')
                foreach ($pm in $pMatches) {
                    $pVal = $pm.Groups[1].Value
                    if ($pVal -match '^\s*(?:motor|[A-Za-z0-9_]+)\s+[A-Za-z0-9_]+\s*=\s*[A-Za-z0-9_]+\(') {
                        # Skip declaration code lines - they belong in Prototype tab
                        continue
                    }
                    if ($pVal -match '^\s*(?:<code>)?([A-Za-z0-9_]+)(?:</code>)?\s*=\s*(.+)$') {
                        $pName = $matches[1]
                        $pDesc = $matches[2] -replace '^\s+', ''
                        if (-not $ctorParams.Contains($pName)) {
                            $ctorParams[$pName] = $pDesc
                        }
                        continue
                    }
                    if ($pVal -notmatch '<strong>Returns:</strong>' -and $pVal.Trim().Length -gt 0) {
                        $cleanDescParas += "<p>$( Clean-HtmlContent $pVal )</p>"
                    }
                }
                $descParas = $cleanDescParas
                $isWaiting = $false
                $isNonWaiting = $false

                if ($ctorParams.Count -gt 0 -and [string]::IsNullOrWhiteSpace($tableHtml)) {
                    $tRows = ""
                    $rIdx = 0
                    foreach ($k in $ctorParams.Keys) {
                        $rClass = if ($rIdx % 2 -eq 0) { "row-even" } else { "row-odd" }
                        $tRows += "    <tr class=`"$rClass`"><td>$k</td><td>$( Clean-HtmlContent $ctorParams[$k] )</td></tr>`n"
                        $rIdx++
                    }
                    $tableHtml = @"
<table border="1" class="docutils">
  <colgroup>
    <col width="22%" />
    <col width="78%" />
  </colgroup>
  <thead valign="bottom">
    <tr class="row-odd"><th class="head">Parameters</th><th class="head">&#160;</th></tr>
  </thead>
  <tbody valign="top">
$tRows  </tbody>
</table>
"@
                }
            } else {
                $pMatches = [regex]::Matches($bodyWithoutTable, '(?s)<p>(.*?)</p>')
                $descParas = @()
                $isWaiting = $false
                $isNonWaiting = $false

                foreach ($pm in $pMatches) {
                    $pVal = $pm.Groups[1].Value
                    if ($pVal -match 'non-waiting') {
                        $isNonWaiting = $true
                    } elseif ($pVal -match '\bwaiting\b' -and $pVal -notmatch 'non-waiting') {
                        $isWaiting = $true
                    }
                    if ($pVal -notmatch '<strong>Returns:</strong>') {
                        $descParas += "<p>$( Clean-HtmlContent $pVal )</p>"
                    }
                }
            }

            # Prototype generation
            $protoCode = ""
            if ($isConstructor) {
                $liMatches = [regex]::Matches($secBody, '<li><p>(?:[A-Za-z0-9_]+\s+[A-Za-z0-9_]+\s*=\s*)?([A-Za-z0-9_]+\([^;]+\));</p>')
                if ($liMatches.Count -gt 0) {
                    $protos = @()
                    foreach ($lm in $liMatches) {
                        $cCall = $lm.Groups[1].Value
                        $cArgs = ($cCall -replace '^[A-Za-z0-9_]+\(', '') -replace '\)$', ''
                        $protos += Format-CppPrototype $className $className $cArgs "void" $tableHtml
                    }
                    $protoCode = $protos -join "`n"
                } else {
                    $ctorCmdMatch = [regex]::Match($secBody, '<code>([A-Za-z0-9_]+)\(([^)]*)\)</code>')
                    if ($ctorCmdMatch.Success) {
                        $protoCode = Format-CppPrototype $className $className $ctorCmdMatch.Groups[2].Value "void" $tableHtml
                    } elseif ($tableHtml -match 'port|index') {
                        $protoCode = Format-CppPrototype $className $className "port" "void" $tableHtml
                    } else {
                        $protoCode = "$className();"
                    }
                }
            } else {
                $protoCmdMatch = [regex]::Match($secBody, '(?:The\s+)?<code>(?:[A-Za-z0-9_]+\.)?([A-Za-z0-9_]+)\(([^)]*)\)</code>')
                if ($protoCmdMatch.Success) {
                    $mName = $protoCmdMatch.Groups[1].Value
                    $mArgs = $protoCmdMatch.Groups[2].Value
                    $protoCode = Format-CppPrototype $className $mName $mArgs $returnsText $tableHtml
                } else {
                    $protoCode = Format-CppPrototype $className $cleanTitleName "" $returnsText $tableHtml
                }
            }

            # Group Category
            $funcCat = "Functions"
            if ($isConstructor) {
                $funcCat = "Constructor(s)"
            } elseif ($cleanTitle -match '^(spin|drive|turn|stop|open|close|set|fire|voltage)') {
                $funcCat = "Movement Functions"
            } elseif ($cleanTitle -match '^(position|velocity|current|power|torque|efficiency|temperature|heading|rotation|angle|pitch|roll|yaw|is|installed|value|direction|gyroRate|acceleration|quality|hue|brightness)') {
                $funcCat = "Telemetry Functions"
            } elseif ($cleanTitle -match '^(setVelocity|setReversed|setStopping|setMaxTorque|setTimeout|setPosition|resetPosition|calibrate|setHeading|setRotation|setTurnType|setLight|setLightPower|tarePosition|setMode)') {
                $funcCat = "Configuration Functions"
            }

            $secObj = @{
                id = $secId
                rawTitle = $secTitle
                cleanTitle = $cleanTitle
                desc = ($descParas -join "`n")
                proto = $protoCode
                example = $exampleCode
                table = $tableHtml
                returns = $returnsText
                isWaiting = $isWaiting
                isNonWaiting = $isNonWaiting
            }

            $sectionsByCat[$funcCat] += $secObj

            # Search entry
            $fileUrl = if ($dest.StartsWith("api/cpp/")) { $dest.Substring("api/cpp/".Length) } else { $dest }
            $globalSearchIndex += @{
                title = "$className::$cleanTitle"
                category = "$pageTitle C++ API"
                url = "$fileUrl#$secId"
                desc = if ($descParas.Count -gt 0) { ($descParas[0] -replace '<[^>]+>', '') } else { "" }
            }
        }
    }

        # Build On-Page TOC matching PROS layout
        $tocHtml = @"
<div class="contents local topic" id="contents">
  <ul class="simple">
    <li><a class="reference internal" href="#functions" id="toc-functions">Functions</a>
      <ul>
"@
        foreach ($catKey in $sectionsByCat.Keys) {
            $catItems = $sectionsByCat[$catKey]
            if ($catItems.Count -gt 0) {
                $catId = $catKey.ToLower() -replace '[^a-z0-9]+', '-'
                $tocHtml += @"
        <li><a class="reference internal" href="#$catId" id="toc-$catId">$catKey</a>
          <ul>
"@
                foreach ($ci in $catItems) {
                    $tocHtml += @"
            <li><a class="reference internal" href="#$($ci.id)" id="toc-$($ci.id)">$($ci.cleanTitle)</a></li>
"@
                }
                $tocHtml += @"
          </ul>
        </li>
"@
            }
        }
        $tocHtml += @"
      </ul>
    </li>
  </ul>
</div>
"@

        # Build Main Content Sections
        $sectionsHtml = ""
        $tabCounter = 0
        foreach ($catKey in $sectionsByCat.Keys) {
            $catItems = $sectionsByCat[$catKey]
            if ($catItems.Count -gt 0) {
                $catId = $catKey.ToLower() -replace '[^a-z0-9]+', '-'
                $sectionsHtml += @"
<div class="section" id="$catId">
  <h3><a class="toc-backref" href="#toc-$catId">$catKey</a><a class="headerlink" href="#$catId" title="Permalink to this headline"></a></h3>
"@
                foreach ($ci in $catItems) {
                    $tabCounter++
                    $badgeHtml = ""
                    if ($ci.isNonWaiting) {
                        $badgeHtml = " <span class=`"badge-nonwaiting`">Non-Waiting</span>"
                    } elseif ($ci.isWaiting) {
                        $badgeHtml = " <span class=`"badge-waiting`">Waiting</span>"
                    }

                    $protoPyg = Format-PygmentsCpp $ci.proto
                    $examCode = if ($ci.example) { $ci.example } else { "// No example provided in official VEXcode API." }
                    $examPyg = Format-PygmentsCpp $examCode

                    $returnsBlock = if ($ci.returns) {
                        "<p><strong>Returns:</strong> $($ci.returns)</p>"
                    } else { "" }

                    $tabsHtml = @"
    <div class="sphinx-tabs docutils container">
      <div class="ui top attached tabular menu sphinx-menu docutils container">
        <div class="active item sphinx-data-tab-$tabCounter-0 docutils container">
          <div class="docutils container">
            Prototype
          </div>
        </div>
        <div class="item sphinx-data-tab-$tabCounter-1 docutils container">
          <div class="docutils container">
            Example
          </div>
        </div>
      </div>
      <div class="ui bottom attached sphinx-tab tab segment code-tab sphinx-data-tab-$tabCounter-0 active docutils container">
        <div class="highlight-cpp notranslate">
          <div class="highlight">
            <pre>$protoPyg</pre>
          </div>
        </div>
      </div>
      <div class="ui bottom attached sphinx-tab tab segment code-tab sphinx-data-tab-$tabCounter-1 docutils container">
        <div class="highlight-cpp notranslate">
          <div class="highlight">
            <pre>$examPyg</pre>
          </div>
        </div>
      </div>
    </div>
"@

                    $sectionsHtml += @"
  <div class="section" id="$($ci.id)">
    <h4><a class="toc-backref" href="#toc-$($ci.id)">$($ci.cleanTitle)</a><a class="headerlink" href="#$($ci.id)" title="Permalink to this headline"></a>$badgeHtml</h4>
    $($ci.desc)
    $tabsHtml
    $($ci.table)
    $returnsBlock
  </div>
  <hr class="docutils" />
"@
                }
                $sectionsHtml += @"
</div>
"@
            }
        }

        $pageSlug = ($pageTitle.ToLower() -replace '[^a-z0-9]+', '-') + "-c-api"

        $extraNoticeHtml = ""
        if ($dest -eq "api/cpp/pneumatics.html") {
            $extraNoticeHtml = @"
                <div class="admonition important">
                  <p class="first admonition-title">V5RC Competition Pneumatics Note</p>
                  <p class="last">
                    In the VEX V5 Robotics Competition (V5RC), pneumatic systems use manual air reservoir tanks pre-charged before the match with a bicycle hand pump (up to 100 PSI maximum). <strong>Motorized air compressors and pumps are strictly illegal under competition rule &lt;R18&gt;.</strong><br/><br/>
                    Pneumatic cylinders are actuated by 5V solenoid valves connected to the Brain's <strong>3-Wire (ADI) Ports (A&ndash;H)</strong> or an external 3-Wire Expander. Solenoids can be controlled using this dedicated <code>vex::pneumatics</code> class, or configured as a <a class="reference internal" href="digital_out.html"><code>vex::digital_out</code></a> device in the VEXcode Devices window.
                  </p>
                </div>
"@
        } elseif ($dest -eq "api/cpp/digital_out.html") {
            $extraNoticeHtml = @"
                <div class="admonition note">
                  <p class="first admonition-title">Common Application: V5 Pneumatics Solenoids</p>
                  <p class="last">
                    In VEXcode V5, <code>digital_out</code> is the primary class configured by the graphical Devices window for pneumatic solenoid valves (Add a device &gt; 3-WIRE &gt; DIGITAL OUT). Calling <code>.set(true)</code> energizes the solenoid to extend the cylinder, and <code>.set(false)</code> de-energizes the solenoid to retract it. For cylinder-specific methods (extend, retract, toggle), see also <a class="reference internal" href="pneumatics.html"><code>vex::pneumatics</code></a>.
                  </p>
                </div>
"@
        }

        # Full HTML file matching exact PROS Sphinx layout
        $pageHtml = @"
<!DOCTYPE html>
<!--[if IE 8]><html class="no-js lt-ie9" lang="en" > <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en" > <!--<![endif]-->
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$pageTitle C++ API &mdash; VEXcode V5 C++ documentation</title>
  <link rel="stylesheet" href="${rel}assets/css/theme.css" type="text/css" />
  <link rel="stylesheet" href="${rel}assets/css/pygments.css" type="text/css" />
  <link rel="stylesheet" href="${rel}assets/css/tabs.css" type="text/css" />
  <link rel="stylesheet" href="${rel}assets/css/pros_extra.css" type="text/css" />
  <link rel="stylesheet" href="${rel}assets/css/pros_modern.css" type="text/css" />
</head>
<body class="wy-body-for-nav" role="document">
  <div class="wy-grid-for-nav">
$( Build-Sidebar $dest $sectionsByCat )
    <section data-toggle="wy-nav-shift" class="wy-nav-content-wrap">
      <nav class="wy-nav-top" role="navigation" aria-label="top navigation">
        <i data-toggle="wy-nav-top" class="fa fa-bars"></i>
        <a href="${rel}index.html">VEXcode V5 C++</a>
      </nav>
      <div class="wy-nav-content">
        <div class="rst-content">
$( Build-Breadcrumbs $dest $pageTitle $catName )
          <div role="main" class="document" itemscope="itemscope" itemtype="http://schema.org/Article">
            <div itemprop="articleBody">
              <div class="section" id="$pageSlug">
                <h1>$pageTitle C++ API<a class="headerlink" href="#$pageSlug" title="Permalink to this headline"></a></h1>
                <div class="admonition note">
                  <p class="first admonition-title">Hardware Specification</p>
                  <p class="last">
                    <strong>Class:</strong> <code>$className</code> &nbsp;|&nbsp;
                    <strong>Port:</strong> $portName &nbsp;|&nbsp;
                    <strong>Competition Status:</strong> V5RC Legal Hardware &nbsp;|&nbsp;
                    <strong>Header:</strong> <code>#include "vex.h"</code>
                  </p>
                </div>
                $extraNoticeHtml

                $tocHtml

                <div class="section" id="functions">
                  <h2><a class="toc-backref" href="#toc-functions">Functions</a><a class="headerlink" href="#functions" title="Permalink to this headline"></a></h2>
                  $sectionsHtml
                </div>
              </div>
            </div>
          </div>
          <footer>
            <hr/>
            <div role="contentinfo">
              <p>&copy; Copyright 2024, VEX Robotics. V5RC Legal Components Reference.</p>
            </div>
          </footer>
        </div>
      </div>
    </section>
  </div>
  <script src="${rel}assets/js/sphinx_tabs.js"></script>
  <script src="${rel}assets/js/search_index.js"></script>
  <script src="${rel}assets/js/search.js"></script>
  <script src="${rel}assets/js/theme.js"></script>
  <script>
    document.addEventListener('DOMContentLoaded', () => {
      if (typeof initSearch === 'function' && typeof searchIndexData !== 'undefined') {
        initSearch(searchIndexData);
      }
    });
  </script>
</body>
</html>
"@

        $targetPath = Join-Path (Get-Location) $dest
        $parentDir = Split-Path $targetPath -Parent
        if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Force -Path $parentDir | Out-Null }
        $pageHtml | Out-File -FilePath $targetPath -Encoding utf8
    }
}

Write-Host "All class documentation pages built!"

# Build search_index.js
$searchJson = $globalSearchIndex | ConvertTo-Json -Compress
$searchScript = "const searchIndexData = $searchJson;"
$searchScript | Out-File -FilePath "assets/js/search_index.js" -Encoding utf8
Write-Host "Wrote assets/js/search_index.js ($($globalSearchIndex.Count) entries)"

# Build api/cpp/index.html (API Overview)
$apiIndexDest = "api/cpp/index.html"
$apiRel = Get-RelativeRoot $apiIndexDest

$apiCardsHtml = ""
foreach ($cat in $categories) {
    if ($cat.name -eq "Getting Started") { continue }
    $catId = $cat.name.ToLower() -replace '[^a-z0-9]+', '-'
    $apiCardsHtml += @"
<div class="section" id="$catId">
  <h2>$($cat.name)<a class="headerlink" href="#$catId" title="Permalink to this headline"></a></h2>
  <div class="api-cards-grid">
"@
    foreach ($p in $cat.pages) {
        $link = if ($p.dest.StartsWith("api/cpp/")) { $p.dest.Substring("api/cpp/".Length) } else { $p.dest }
        $badgeClass = if ($p.port -match 'Smart') { "badge-smartport" } elseif ($p.port -match '3-Wire') { "badge-triport" } else { "badge-system" }
        $apiCardsHtml += @"
    <a href="$link" class="api-card">
      <h3><span>$($p.title)</span> <span>&rarr;</span></h3>
      <div style="margin-bottom:0.45rem;">
        <span class="$badgeClass">$($p.port)</span>
        <code style="font-size:0.75rem;">$($p.className)</code>
      </div>
      <p>$($p.summary)</p>
    </a>
"@
    }
    $apiCardsHtml += "  </div>`n</div>`n"
}

$apiIndexHtml = @"
<!DOCTYPE html>
<!--[if IE 8]><html class="no-js lt-ie9" lang="en" > <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en" > <!--<![endif]-->
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>API Directory &mdash; VEXcode V5 C++ documentation</title>
  <link rel="stylesheet" href="${apiRel}assets/css/theme.css" type="text/css" />
  <link rel="stylesheet" href="${apiRel}assets/css/pygments.css" type="text/css" />
  <link rel="stylesheet" href="${apiRel}assets/css/tabs.css" type="text/css" />
  <link rel="stylesheet" href="${apiRel}assets/css/pros_extra.css" type="text/css" />
  <link rel="stylesheet" href="${apiRel}assets/css/pros_modern.css" type="text/css" />
</head>
<body class="wy-body-for-nav" role="document">
  <div class="wy-grid-for-nav">
$( Build-Sidebar $apiIndexDest )
    <section data-toggle="wy-nav-shift" class="wy-nav-content-wrap">
      <nav class="wy-nav-top" role="navigation" aria-label="top navigation">
        <i data-toggle="wy-nav-top" class="fa fa-bars"></i>
        <a href="${apiRel}index.html">VEXcode V5 C++</a>
      </nav>
      <div class="wy-nav-content">
        <div class="rst-content">
$( Build-Breadcrumbs $apiIndexDest "API Directory" "" )
          <div role="main" class="document" itemscope="itemscope" itemtype="http://schema.org/Article">
            <div itemprop="articleBody">
              <div class="section" id="vexcode-v5-c-api-directory">
                <h1>VEXcode V5 C++ API Directory<a class="headerlink" href="#vexcode-v5-c-api-directory" title="Permalink to this headline"></a></h1>
                <div class="admonition note">
                  <p class="first admonition-title">V5RC Competition Legal Hardware Reference</p>
                  <p class="last">Welcome to the VEXcode V5 C++ API Reference. Select any competition-legal hardware component, sensor, or system module below to inspect full function prototypes, parameter tables, execution wait semantics, and verified example code.</p>
                </div>

                $apiCardsHtml
              </div>
            </div>
          </div>
          <footer>
            <hr/>
            <div role="contentinfo">
              <p>&copy; Copyright 2024, VEX Robotics. V5RC Legal Components Reference.</p>
            </div>
          </footer>
        </div>
      </div>
    </section>
  </div>
  <script src="${apiRel}assets/js/sphinx_tabs.js"></script>
  <script src="${apiRel}assets/js/search_index.js"></script>
  <script src="${apiRel}assets/js/search.js"></script>
  <script src="${apiRel}assets/js/theme.js"></script>
  <script>
    document.addEventListener('DOMContentLoaded', () => {
      if (typeof initSearch === 'function' && typeof searchIndexData !== 'undefined') {
        initSearch(searchIndexData);
      }
    });
  </script>
</body>
</html>
"@

$apiIndexHtml | Out-File -FilePath "api/cpp/index.html" -Encoding utf8
Write-Host "Wrote api/cpp/index.html"

# Build root index.html (Documentation Home)
$rootDest = "index.html"
$rootRel = Get-RelativeRoot $rootDest

$homeCardsHtml = ""
foreach ($cat in $categories) {
    if ($cat.name -eq "Getting Started") { continue }
    $pageTitles = ($cat.pages | ForEach-Object { $_["title"] }) -join ', '
    $firstPage = $cat.pages[0]
    $firstLink = $firstPage.dest
    $homeCardsHtml += @"
<a href="$firstLink" class="api-card">
  <h3><span>$($cat.name)</span> <span>&rarr;</span></h3>
  <p>Reference documentation for $pageTitles.</p>
</a>
"@
}

$sampleCode = @"
#include "vex.h"

using namespace vex;

// Global brain instance
brain Brain;

// Example V5RC smart motor and bumper switch
motor LeftMotor = motor(PORT1, ratio18_1, false);
bumper LimitSwitch = bumper(Brain.ThreeWirePort.A);

int main() {
    // Initializing Robot Configuration. DO NOT REMOVE!
    vexcodeInit();
    
    Brain.Screen.print("Robot Initialized.");
    
    // Spin motor forward at 100 RPM
    LeftMotor.spin(forward, 100, rpm);
    
    while (true) {
        if (LimitSwitch.pressing()) {
            LeftMotor.stop(brakeType::brake);
        }
        wait(20, msec);
    }
}
"@

$sampleCodePyg = Format-PygmentsCpp $sampleCode

$rootIndexHtml = @"
<!DOCTYPE html>
<!--[if IE 8]><html class="no-js lt-ie9" lang="en" > <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en" > <!--<![endif]-->
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VEXcode V5 C++ Documentation</title>
  <link rel="stylesheet" href="${rootRel}assets/css/theme.css" type="text/css" />
  <link rel="stylesheet" href="${rootRel}assets/css/pygments.css" type="text/css" />
  <link rel="stylesheet" href="${rootRel}assets/css/tabs.css" type="text/css" />
  <link rel="stylesheet" href="${rootRel}assets/css/pros_extra.css" type="text/css" />
  <link rel="stylesheet" href="${rootRel}assets/css/pros_modern.css" type="text/css" />
</head>
<body class="wy-body-for-nav" role="document">
  <div class="wy-grid-for-nav">
$( Build-Sidebar $rootDest )
    <section data-toggle="wy-nav-shift" class="wy-nav-content-wrap">
      <nav class="wy-nav-top" role="navigation" aria-label="top navigation">
        <i data-toggle="wy-nav-top" class="fa fa-bars"></i>
        <a href="${rootRel}index.html">VEXcode V5 C++</a>
      </nav>
      <div class="wy-nav-content">
        <div class="rst-content">
$( Build-Breadcrumbs $rootDest "Documentation Home" "" )
          <div role="main" class="document" itemscope="itemscope" itemtype="http://schema.org/Article">
            <div itemprop="articleBody">
              <div class="section" id="vexcode-v5-c-documentation">
                <h1>VEXcode V5 C++ Documentation<a class="headerlink" href="#vexcode-v5-c-documentation" title="Permalink to this headline"></a></h1>

                <div class="section" id="api-categories">
                  <h2>API Categories<a class="headerlink" href="#api-categories" title="Permalink to this headline"></a></h2>
                  <div class="api-cards-grid">
                    $homeCardsHtml
                  </div>
                </div>

                <div class="section" id="getting-started">
                  <h2>Getting Started with VEXcode C++<a class="headerlink" href="#getting-started" title="Permalink to this headline"></a></h2>
                  <p>Every VEXcode V5 C++ program requires the master header file and standard namespace declaration. Standard motion loops should include a cooperative sleep using <code>wait(20, msec);</code>:</p>

                  <div class="highlight-cpp notranslate">
                    <div class="highlight">
                      <pre>$sampleCodePyg</pre>
                    </div>
                  </div>
                </div>

                <div class="section" id="hardware-addressing-ports">
                  <h2>Hardware Addressing &amp; Ports<a class="headerlink" href="#hardware-addressing-ports" title="Permalink to this headline"></a></h2>
                  <table border="1" class="docutils">
                    <colgroup>
                      <col width="28%" />
                      <col width="26%" />
                      <col width="46%" />
                    </colgroup>
                    <thead valign="bottom">
                      <tr class="row-odd">
                        <th class="head">Hardware Type</th>
                        <th class="head">Port Definition</th>
                        <th class="head">Example Constructor</th>
                      </tr>
                    </thead>
                    <tbody valign="top">
                      <tr class="row-even">
                        <td><strong>Smart Port (1&ndash;21)</strong></td>
                        <td><code>PORT1</code> &ndash; <code>PORT21</code></td>
                        <td><code>motor LeftMotor = motor(PORT1, ratio18_1, false);</code></td>
                      </tr>
                      <tr class="row-odd">
                        <td><strong>3-Wire TriPort (A&ndash;H)</strong></td>
                        <td><code>Brain.ThreeWirePort.A</code> &ndash; <code>.H</code></td>
                        <td><code>bumper LimitSwitch = bumper(Brain.ThreeWirePort.A);</code></td>
                      </tr>
                      <tr class="row-even">
                        <td><strong>Controller</strong></td>
                        <td><code>controller(primary)</code></td>
                        <td><code>controller Master = controller(primary);</code></td>
                      </tr>
                    </tbody>
                  </table>
                </div>

                <div class="section" id="execution-model">
                  <h2>Execution Model: Waiting vs Non-Waiting Commands<a class="headerlink" href="#execution-model" title="Permalink to this headline"></a></h2>
                  <div class="admonition note">
                    <p class="first admonition-title">Command Execution Behavior</p>
                    <p>In VEXcode C++, hardware actuation functions are categorized as either <strong>Waiting</strong> or <strong>Non-Waiting</strong>:</p>
                    <ul class="last">
                      <li><strong>Non-Waiting Functions</strong> (e.g. <code>Motor.spin(forward);</code>, <code>Drivetrain.drive(forward);</code>): Return execution control immediately while the motor continues to spin in the background.</li>
                      <li><strong>Waiting Functions</strong> (e.g. <code>Motor.spinFor(2, turns);</code>, <code>Drivetrain.driveFor(24, inches);</code>): Block program execution until the movement completes or the command timeout elapses.</li>
                      <li><strong>Optional Asynchronous Parameter</strong>: Most waiting commands accept an optional trailing boolean parameter (<code>wait = false</code>) to dispatch the motion asynchronously without blocking thread execution.</li>
                    </ul>
                  </div>

                  <div style="text-align:center; margin: 2.5rem 0 1.5rem;">
                    <a href="api/cpp/index.html" style="display:inline-block; padding:0.75rem 2rem; background:#B89349; color:#fff; font-weight:700; border-radius:4px; text-decoration:none; box-shadow: 0 2px 6px rgba(0,0,0,0.15); transition: background 0.2s ease;">Browse Complete API Reference &rarr;</a>
                  </div>
                </div>

              </div>
            </div>
          </div>
          <footer>
            <hr/>
            <div role="contentinfo">
              <p>&copy; Copyright 2024, VEX Robotics. V5RC Legal Components Reference.</p>
            </div>
          </footer>
        </div>
      </div>
    </section>
  </div>
  <script src="${rootRel}assets/js/sphinx_tabs.js"></script>
  <script src="${rootRel}assets/js/search_index.js"></script>
  <script src="${rootRel}assets/js/search.js"></script>
  <script src="${rootRel}assets/js/theme.js"></script>
  <script>
    document.addEventListener('DOMContentLoaded', () => {
      if (typeof initSearch === 'function' && typeof searchIndexData !== 'undefined') {
        initSearch(searchIndexData);
      }
    });
  </script>
</body>
</html>
"@

$rootIndexHtml | Out-File -FilePath "index.html" -Encoding utf8
Write-Host "Wrote root index.html"

Write-Host "BUILD COMPLETE!"

