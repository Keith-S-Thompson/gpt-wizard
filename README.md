UPDATE Mon 2019-07-22

This is a copy of the gpt-wizard sources, translated
from CVS to Git.  The original web page for the project,
    http://users.sdsc.edu/~kst/gpt-wizard
no longer exists.  The `releases/` directory contains `*.tar.gz`
releases of the tool.

The script I used to translate from CVS to Git is a work in progress.
In particular, CVS symbolic names (mostly marking releases) that
were applied to multiple files are applied only to the most recently
committed file in this git repo.  You can't generally see release tags
by running `git log` on an individual file, but you can `git checkout`
a tag and see the files that made up that release.

`gpt-wizard` was designed to work with releases of Globus as it existed
when I worked at SDSC up to 2007.  I haven't kept up with Globus
since leaving SDSC, but gpt-wizard is likely not necessary or useful
for current Globus releases.

I'm making it available here just to show off some work that I've
done in the past, not with any intent for it to be useful -- though if
someone can make some use of it, that's great.  (There are certainly
things I'd change if I were still working on it, starting with running
it through perlcritic.)

My email address listed in the documentation, <kst@sdsc.edu>,
is no longer valid.  My personal email address is
<Keith.S.Thompson@gmail.com>.

This is `README.md`, created to go with this Git repo.  The `README`
file was part of the released too, and was last updated in 2004.
