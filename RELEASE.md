[![](https://img.shields.io/cpan/v/Math-PRBS.svg?colorB=00CC00 "metacpan")](https://metacpan.org/pod/Math::PRBS)
[![](http://cpants.cpanauthors.org/dist/Math-PRBS.png "cpan testers")](http://matrix.cpantesters.org/?dist=Math-PRBS)
[![](https://img.shields.io/github/release/pryrt/Math-PRBS.svg "github release")](https://github.com/pryrt/Math-PRBS/releases)
[![](https://img.shields.io/github/issues/pryrt/Math-PRBS.svg "issues")](https://github.com/pryrt/Math-PRBS/issues)
[![](https://ci.appveyor.com/api/projects/status/cj6cbq7u9velb8wx?svg=true "appveyor build status")](https://ci.appveyor.com/project/pryrt/math-prbs)
[![](https://github.com/pryrt/Math-PRBS/actions/workflows/perl-ci.yml/badge.svg "gh action build status")](https://github.com/pryrt/Math-PRBS/actions/workflows/perl-ci.yml)
[![](https://coveralls.io/repos/github/pryrt/Math-PRBS/badge.svg?branch=main "test coverage")](https://coveralls.io/github/pryrt/Math-PRBS?branch=main)

# Releasing Math::PRBS

This describes some of my methodology for releasing a distribution.  To help with testing and coverage, I've integrated the [GitHub repo](https://github.com/pryrt/Math-PRBS/) with [Travis-CI](https://travis-ci.org/pryrt/Math-PRBS) and [coveralls.io](https://coveralls.io/github/pryrt/Math-PRBS)

## My Methodology

I use a local svn client to checkout the GitHub repo.  All these things can be done with a git client, but the terminology changes, and I cease being comfortable.

* **Development:**

    * **GitHub:** create a branch

    * **svn:** switch from trunk to branch

    * `prove -l t` for normal tests, `prove -l xt` for author tests
    * use `berrybrew exec` or `perlbrew exec` on those `prove`s to get a wider suite
    * every `svn commit` to the GitHub repo should trigger Travis-CI build suite

* **Release:**

    * **Verify Documentation:**
        * make sure versioning is correct
        * verify POD and README
        * verify HISTORY

    * **Build Distribution**

            gmake veryclean         # clear out all the extra junk
            perl Makefile.PL        # create a new makefile
            gmake                   # copy the library to ./blib/lib...
            gmake distcheck         # if you want to check for new or removed files
            gmake manifest          # if distcheck() showed discrepancies
            gmake disttest          # optional, if you want to verify that make test will work for the CPAN audience
            set MM_SIGN_DIST=1      # enable signatures for build
            set TEST_SIGNATURE=1    # verify signatures during `distauthtest`
            perl Makefile.PL        # need to regenerate Makefile once MM_SIGN_DIST is enabled
            gmake distauthtest      # run author tests (which will test the signature)
            set TEST_SIGNATURE=     # clear signature verification during `disttest`
            gmake dist              # actually make the tarball
            gmake veryclean         # clean out this directory
            set MM_SIGN_DIST=       # clear signatures after build

            # verify the signature inside the tarball using cpanm:
            cpanm --look *.gz
            cpansign -v
            exit

    * **svn:** final commit of the development branch

    * **GitHub:** make a pull request to bring the branch back into the trunk
        * This should trigger Travis-CI approval for the pull request
        * Once Travis-CI approves, need to approve the pull request, then the branch will be merged back into the trunk
        * If that branch is truly done, delete the branch using the pull-request page

    * **GitHub:** [create a new release](https://help.github.com/articles/creating-releases/):
        * Releases > Releases > Draft a New Release
        * tag name = `v#.###`
        * release title = `v#.###`

    * **PAUSE:** [upload distribution tarball to CPAN/PAUSE](https://pause.perl.org/pause/authenquery?ACTION=add_uri) by browsing to the file on my computer.
        * Watch <https://metacpan.org/author/PETERCJ> and <http://search.cpan.org/~petercj/> for when it updates
        * Clear out any [GitHub issues](https://github.com/pryrt/Math-PRBS/issues/)


<style>
body { font-family: sans-serif; }
code {
    font-family: monospace;
    white-space: pre;
    display: inline;
    border: 1px solid #677;
    border-radius: 4px;
    padding: 0 2px;
    background: #cff;
}
pre code {
    display: block;
}
blockquote {
    font-style: italic;
    font-size: smaller;
    color: grey;
    border-left: 1px dotted black;
    padding-left: 1ex;
}
</style>
