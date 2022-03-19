# NOT CREATED OR MAINTAINED BY LPTSTR OR MEMBERS
# ----------- from lukesampson/scoop -----------
# renamed getargs from getopt so as to not interfere
# with Linux getopt tool
# --------------------- LICENSE --------------------
# Unlicense (See github.com/lukesampson/scoop/blob/master/LICENSE)

# ---------------------- START -------------------------
# adapted from http://hg.python.org/cpython/file/2.7/Lib/getopt.py
# argv:
#    array of arguments
# shortopts:
#    string of single-letter options. options that take a parameter
#    should be follow by ':'
# longopts:
#    array of strings that are long-form options. options that take
#    a parameter should end with '='
# returns @(opts hash, remaining_args array, error string)
# ---------------------- modification -------------------------
# date :  modification
# 2022-03-19 : shortopts shoud not be sorted
# 2022-03-02 : add unknown options to rem, int, double type goes to string

function getargs($argv, $shortopts, $longopts) {
    $opts = @{}; $rem = @()

    function err($msg) {
        $opts, $rem, $msg
    }

    function regex_escape($str) {
        return [regex]::escape($str)
    }

    # ensure these are arrays
    $argv = @($argv)
    $longopts = @($longopts)
    
    # if user add duplicate options then key contaminated, get uniq array
    $longopts = $longopts |Sort-Object -Unique

    for($i = 0; $i -lt $argv.length; $i++) {
        $arg = $argv[$i]
        if($null -eq $arg) { continue }
        # don't try to parse array arguments
        if($arg -is [array])    { $rem += ,$arg; continue }
        if($arg -is [int])      { $arg = [String] $arg; continue }
        if($arg -is [decimal])  { $arg = [String] $arg; continue }
        if($arg -is [Double])   { $arg = [String] $arg; continue }
        # modified not to parse 3.6 as decimal

        if($arg.startswith('--')) {
            #$name = $arg.substring(2)
            $slice_arg = $arg.substring(2)  -Split '=' , 2  #  key=valueww  => $slice_arg[0], $slice_arg[1], key value : $slice_arg[0]
            
            $name = $slice_arg[0]
            $longopt = $longopts | Where-Object { $_ -match "^$name=?$" }

            #Write-Host "name : [$name] , slice_arg : [$($slice_arg.length)] , longopt (  $longopt )"
            # modified to accept --color=blue with --color blue 
            if($longopt) {
                if($slice_arg.length -gt 1) { 
                    $opts.$name = $slice_arg[1]
                }
                elseif($longopt.endswith('=')) { # requires arg
                    if($i -eq $argv.length - 1) {
                        return err "Option --$name requires an argument."
                    }
                    $opts.$name = $argv[++$i]
                } else {
                    $opts.$name = $true
                }
            } else {
                #return err "Option --$name not recognized."
                # modified not to break
                $rem += "--$name"
            }
        } elseif($arg.startswith('-') -and $arg -ne '-') {
#            Write-Host "arg: $arg"
            for($j = 1; $j -lt $arg.length; $j++) {
                $letter = $arg[$j].tostring()

                if($shortopts -match "$(regex_escape $letter)`:?") {
                    $shortopt = $matches[0]
                    if($shortopt[1] -eq ':') {
                        if($j -ne $arg.length -1 -or $i -eq $argv.length - 1) {
                            return err "Option -$letter requires an argument."
                        }
                        $opts.$letter = $argv[++$i]
                    } else {
                        $opts.$letter = $true
                    }
                } else {
                    #return err "Option -$letter not recognized."
                    # modified not to break 
   
                    if ($arg -ceq "-$letter") {
                        $rem += "-$letter"
                    } else {
                        $rem += $letter
                    }
                    
                }
            }
        } else {
            #Write-Host "adding arg to rem: $arg "
            $rem += $arg
        }
    }

    $opts, $rem
}

# --------------------- EOF ------------------------
