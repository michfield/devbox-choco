$pkg = "Devbox-opts"

# Refresh environment from registry
Update-SessionEnvironment


# Helper function to get the list of specified registry value or null
# if it is missing.
#
function Get-RegistryValue($path, $name)
{
    $path.Split(';')  | Select-Object -unique | ?{!([System.String]::IsNullOrEmpty($_))} | %{
        if (Test-Path -LiteralPath "$_") {
            $(Get-Item -LiteralPath "$_").GetValue($name, $null)
        }
    }
}

try {

    # Initialize hash for saved values
    $save = @{}

    # Detect Git
    #
    $apps = @(Show-AppUninstallInfo -match "Git version [0-9\.]+-preview\d*")
    if ($apps.Length -eq 0)
    {
        throw "Could not detect a valid Git installation"
    }

    $app = $apps[0]
    $gitDir = $app["InstallLocation"]

    if (-not (Test-Path "$gitDir"))
    {
        throw "Local Git installation is detected, but directories are not accessible or have been removed"
    }

    Write-Host ""
    Write-Host "Git $($app["DisplayVersion"]) detected:`n  » $gitDir" -foregroundcolor yellow
    $exeGit = Join-Path "$gitDir" "bin\git.exe"

    # Git (\cmd) and its tools (\bin) must be in the PATH
    #
    Install-ChocolateyPath $(Join-Path "$gitDir" "bin")
    Install-ChocolateyPath $(Join-Path "$gitDir" "cmd")

    # Editor
    #
    # The best one for this task is notepad2. It's very fast and light,
    # and has syntax highlightning. For my taste, Notepad++ is too big.
    # Also, there are forks of notepad2, but I don't see a point in them
    # because I just want fast & light notepad replacement with syntax.
    #
    Write-Host ""

    $original = $(& "$exeGit" config --get core.editor)
    if (!$original)
    {
        # Detect editor
        #
        $apps = @(Show-AppUninstallInfo -match "Notepad\+\+")
        if ($apps.Length -gt 0)
        {
            $app = $apps[0]

            # Notepad++ is installed, but stupid fucker doesn't have
            # valid InstallLocation value. So I must dig in registry.
            #
            $dirEditor = Get-RegistryValue "HKLM:\Software\Wow6432Node\Notepad++" "" | select -first 1
            $exeEditor = Find-FileInPath "notepad++.exe" "$dirEditor"

            if ($exeEditor)
            {
                & "$exeGit" config --global core.editor "'$exeEditor' -multiInst -notabbar -nosession -noPlugins"
                Write-Host "Git editor set to:`n  » Notepad++ $($app["DisplayVersion"]) » $exeEditor" -foregroundcolor yellow
            }
        }

        if (!$exeEditor)
        {
            # Try notepad2 (notepad)
            #
            # Use notepad without any special detection, because it will
            # always start notepad2 if it's installed
            #
            $dirs = @("${env:WinDir}","${env:WinDir}\System32")
            $exeEditor = Find-FileInPath "notepad.exe" "$($dirs -join ";")"

            if ($exeEditor)
            {
                & "$exeGit" config --global core.editor "\`"$exeEditor\`""
                Write-Host "Git editor set to:`n  » Notepad / Notepad2 » $exeEditor" -foregroundcolor yellow
            }
        }

        if (!$exeEditor)
        {
            Write-Host "Git editor:`n  » No tool detected. Nothing has changed." -foregroundcolor yellow
        }
    }
    else
    {
        $save["core.editor"] = $original
        Write-Host "Git editor:`n  » Skip. Already set to $original" -foregroundcolor yellow
    }

    # Diff & Merge Tool
    # The best one is P4Merge, and if not installed then try DiffMerge
    #
    # mergetool.keepBackup = false
    #   To have merge tool stop creating the *.orig files on merge
    #
    # mergetool.prompt = false
    #   Annoying prompt asks you which merge tool to use. It is only really
    #   useful if you have multiple merge tools configured. By setting
    #   value to false, Git will use default merge tool automatically
    #   without prompting.
    #

    Write-Host ""

    $original = $(& "$exeGit" config --get diff.tool)
    if (!$original -or ($original -match "kdiff"))
    {
        # Detect
        $apps = @(Show-AppUninstallInfo -match "Perforce Visual Components")
        if ($apps.Length -gt 0)
        {
            $app = $apps[0]

            # It's installed, but there is no valid InstallLocation
            # value. So I must dig in registry.
            #
            $dirDiff = Get-RegistryValue "HKLM:\Software\Wow6432Node\Perforce\Environment" "P4INSTROOT" | select -first 1
            $exeDiff = Find-FileInPath "p4merge.exe" "$dirDiff"

            if ($exeDiff)
            {
                & "$exeGit" config --global difftool.p4merge.cmd "\`"$exeDiff\`" \`"`$LOCAL\`" \`"`$REMOTE\`""

                & "$exeGit" config --global mergetool.p4merge.cmd "\`"$exeDiff\`" \`"`$BASE\`" \`"`$LOCAL\`" \`"`$REMOTE\`" \`"`$MERGED\`""
                & "$exeGit" config --global mergetool.p4merge.trustExitCode true

                & "$exeGit" config --global diff.tool p4merge
                & "$exeGit" config --global diff.guitool p4merge
                & "$exeGit" config --global difftool.prompt false

                & "$exeGit" config --global merge.tool p4merge
                & "$exeGit" config --global mergetool.keepBackup false
                & "$exeGit" config --global mergetool.prompt false

                Write-Host "Git diff and merge tool:`n  » P4Merge $($app["DisplayVersion"]) » $exeDiff" -foregroundcolor yellow
            }
        }

        if (!$exeDiff)
        {
            # Try DiffMerge
            #

            $apps = @(Show-AppUninstallInfo -match "SourceGear DiffMerge")
            if ($apps.Length -gt 0)
            {
                $app = $apps[0]

                # Install Location is NOT set, so we must somehow
                # detect where is installed
                #
                $dirs = Join-Path @("${env:ProgramFiles}","${env:ProgramFiles(x86)}") "SourceGear\Common\DiffMerge"
                $exeDiff = Find-FileInPath "sgdm.exe" $($dirs -join ";")

                if ($exeDiff)
                {
                    & "$exeGit" config --global difftool.diffmerge.cmd "\`"$exeDiff\`" --merge --result=\`"`$MERGED\`" \`"`$LOCAL\`" \`"`$BASE\`" \`"`$REMOTE\`" --title1=\`"Theirs\`" --title2=\`"Merging to: `$MERGED\`" --title3=\`"Mine\`""
                    & "$exeGit" config --global mergetool.diffmerge.cmd "\`"$exeDiff\`" \`"`$LOCAL\`" \`"`$REMOTE\`" --title1=\`"Previous Version (`$LOCAL)\`" --title2=\`"Current Version (`$REMOTE)\`""
                    & "$exeGit" config --global mergetool.diffmerge.trustExitCode true

                    & "$exeGit" config --global diff.tool diffmerge
                    & "$exeGit" config --global diff.guitool diffmerge
                    & "$exeGit" config --global difftool.prompt false

                    & "$exeGit" config --global merge.tool diffmerge
                    & "$exeGit" config --global mergetool.keepBackup false
                    & "$exeGit" config --global mergetool.prompt false

                    Write-Host "Git diff and merge tool:`n  » DiffMerge $($app["DisplayVersion"]) » $exeDiff" -foregroundcolor yellow
                }
            }
        }

        if (!$exeDiff)
        {
            Write-Host "Git diff and merge tool:`n  » No tool detected. Nothing has changed." -foregroundcolor yellow
        }
    }
    else
    {
        $save["diff.tool"]              = $original
        $save["diff.guitool"]           = $(& "$exeGit" config --get diff.guitool)
        $save["difftool.prompt"]        = $(& "$exeGit" config --get difftool.prompt)

        $save["merge.tool"]             = $(& "$exeGit" config --get merge.tool)
        $save["mergetool.keepBackup"]   = $(& "$exeGit" config --get mergetool.keepBackup)
        $save["mergetool.prompt"]       = $(& "$exeGit" config --get mergetool.prompt)

        Write-Host "Git diff and merge tool:`n  » Skip. Already set to $original" -foregroundcolor yellow
    }

    Write-Host ""
    Write-Host "Git config:" -foregroundcolor yellow

    # Very simple set of standard Git config on Windows.
    #
    # help.autocorrect = 1
    #   Turn on Git's auto-correct feature: if you mistype a command,
    #   Git will automatically run the command if it has only one match
    #   similar.
    #
    # See:
    # https://www.kernel.org/pub/software/scm/git/docs/git-config.html

    $opts = @{}
    $opts["push.default"         ] = "simple"
    $opts["help.autocorrect"     ] = "1"
    $opts["help.format"          ] = "html"
    $opts["rebase.autosquash"    ] = "true"
    $opts["pack.packSizeLimit"   ] = "2g"
    $opts["core.autocrlf"        ] = "false"

    foreach($optName in @($opts.keys))
    {
        $original = [string] $(& "$exeGit" config --get `"$optName`")
        if (!$original)
        {
            $optValue = $opts[$optName]

            & "$exeGit" config --global `"$optName`" `"$optValue`"

            Write-Host "  » ${optName}: " -nonewline
            Write-Host "$optValue" -foregroundcolor yellow
        }
        else
        {
            $save[$optName] = $original
            Write-Host "  » ${optName}: Skip. Already set to " -nonewline
            Write-Host "$original" -foregroundcolor yellow
        }
    }

    Write-Host ""
    Write-Host "Setting Git aliases:" -foregroundcolor yellow

    # Set useful Git aliases
    #

    $opts = @{}
    $opts["alias.aliases"   ] = "config --get-regexp alias"

    $opts["alias.co"        ] = "checkout" # widely used, almost as standard
    $opts["alias.br"        ] = "branch" # widely used, almost as standard

    # Status and diff

        $opts["alias.s"         ] = "status"
        $opts["alias.st"        ] = "status" # widely used, almost as standard
        $opts["alias.d"         ] = "diff"
        $opts["alias.dc"        ] = "diff --cached"
        $opts["alias.stats"     ] = "diff --stat"
        $opts["alias.wdiff"     ] = "diff --word-diff"

    # Stage, unstage

        $opts["alias.a"         ] = "add"
        $opts["alias.unstage"   ] = "reset HEAD --"

    # Commit

        $opts["alias.c"         ] = "commit -m"
        $opts["alias.ci"        ] = "commit" # widely used, almost as standard

        # You want to commit changes as part of the prior commit, and want
        # to keep the original commit message. Similar to creating a new
        # commit and then squashing them.
        #
        $opts["alias.ca"        ] = "commit --amend -C HEAD"

        $opts["alias.undo"      ] = "reset head~"
        $opts["alias.amend"     ] = "commit --amend"

    # Push, pull

        # Pull in upstream changes as often as possible
        $opts["alias.up"        ] = "!git fetch origin && git rebase origin/master"
        $opts["alias.pp"        ] = "!git pull && git push"

    # Clean up the history by squashing commits
    $opts["alias.ir"        ] = "!git rebase -i origin/master"

    # Merge into master, run all tests and push upstream (git done)
    $opts["alias.done"      ] = "!git fetch && git rebase origin/master && git checkout master && git merge @{-1} && git push"

    # Log, history, stats, etc

        $user = $(& "$exeGit" config --get user.name)
        $user = if ($user) { $user } else { $env:Username }

        $opts["alias.standup"   ] = "log --since yesterday --oneline --author '$user'"

        $opts["alias.last"      ] = "log -1 HEAD"

        $opts["alias.l"         ] = "log"
        $opts["alias.l1"        ] = "log --pretty=format:'%s * %an, %ar' --graph"
        $opts["alias.l2"        ] = "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short"
        $opts["alias.l3"        ] = "log --pretty=format:'%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]' --decorate"

        $opts["alias.today"     ] = "log --stat --since='1 day ago' --graph --pretty=oneline --abbrev-commit --date=relative"
        $opts["alias.who"       ] = "shortlog -s -e --no-merges --"
        $opts["alias.hist"      ] = "log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue) [%an]%Creset' --graph --abbrev-commit --date=relative"

    # Miscellaneous
    #
    # It’s a good idea to clean up your git repo every once in a while.
    # This alias will remove remote branch references that no longer
    # exist, cleanup unnecessary git files, remove untracked files from
    # the working tree and clear out your stash.
    #
    $opts["alias.cleanup"   ] = "!git remote prune origin && git gc && git clean -dfx && git stash clear"

    function Truncate([string] $str, [int] $size)
    {
        if ($size -ge $str.Length) { return $str }

        $spc = $str.LastIndexOf(" ", $size)
        $tnc = $str.Substring(0, $(if ($spc -ge 0) { $spc } else { $size }))
        return "$tnc ..."
    }

    # Now, apply all Git aliases
    #
    foreach($optName in @($opts.keys))
    {
        $original = [string] $(& "$exeGit" config --get `"$optName`")
        if (!$original)
        {
            $optValue = $opts[$optName]

            & "$exeGit" config --global `"$optName`" `"$optValue`"

            Write-Host "  » ${optName}: " -nonewline
            Write-Host $(Truncate $optValue 55) -foregroundcolor yellow
        }
        else
        {
            $save[$optName] = $original

            Write-Host "  » ${optName}: Skip. Already set to " -nonewline
            Write-Host $(Truncate $original 35) -foregroundcolor yellow
        }
    }

    # Setting TERM variable if not set
    #
    Write-Host ""
    Write-Host "System Environment:" -foregroundcolor yellow

    if (-not (Test-Path Env:\Term)) {
        Install-ChocolateyEnvironmentVariable "TERM" "linux"
        Write-Host "  » TERM environment variable: Set to 'linux'" -foregroundcolor yellow
    }
    else {
        Write-Host "  » TERM environment variable: Skip. Already set to '${env:Term}'" -foregroundcolor yellow
    }

    Write-Host ""
    Write-Host "NOTE: Environment variables are set, but NOT for currently running session. There are two solutions for this problem: first one is to execute provided `setenv.bat` to refresh session environment. The second solution is to restart shell by exiting and starting it again."
    Write-Host ""

    # There are no saved values. Because I did not change anything that
    # had any value.
    #
    # foreach ($savName in @($save.keys)) { Write-Host "$savName = $($save["$savName"]))" }

    Write-ChocolateySuccess "$pkg"
}
catch
{
    Write-ChocolateyFailure "$pkg" "$($_.Exception.Message)"
    throw
}


