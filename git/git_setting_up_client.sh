# status in GIT:
# untracked --> changes in local code / workspace, not staged in workspace, not in master stream
# staged with: git add <filename> | <dir> | --all
# see delta: what have changed in the code, untracked, workspace vs stream
git diff
# if staged, but not yet commited, see changes with:
git diff --cached

# removing a file from workspace, and stream:
rm <filename>
git rm <filename>
# + commit and push

# moving files with buil-in-function git mv:
git mv <file1.txt> <filenow.txt>
# + commit and push

# you have updated code, push it:
git status
git add --all # for adding a specific file: git add <filename>
git commit -m "message goes here"
git push origin master
git status



### SCENARIOS: adding a .txt file in workspace, untracked:

[ip14aai@02DI20161235444 workspace_linux_scripts]$ git status
# On branch master
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#	testing.txt
nothing added to commit but untracked files present (use "git add" to track)

[ip14aai@02DI20161235444 workspace_linux_scripts]$ git add testing.txt
[ip14aai@02DI20161235444 workspace_linux_scripts]$ git status
# On branch master
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
#	new file:   testing.txt
#

[ip14aai@02DI20161235444 workspace_linux_scripts]$ git diff --cached
diff --git a/testing.txt b/testing.txt
new file mode 100644
index 0000000..d00491f
--- /dev/null
+++ b/testing.txt
@@ -0,0 +1 @@
+1

###### I HAVE DECIDED TO ADD MORE MODIFICATIONS TO THE SAME FILE, back from staging to untracked code:
[ip14aai@02DI20161235444 workspace_linux_scripts]$ git reset testing.txt
[ip14aai@02DI20161235444 workspace_linux_scripts]$ git status
# On branch master
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#	testing.txt
nothing added to commit but untracked files present (use "git add" to track)

## I have added a new line at 16:12h

[ip14aai@02DI20161235444 workspace_linux_scripts]$ git add testing.txt
[ip14aai@02DI20161235444 workspace_linux_scripts]$ git diff --cached
diff --git a/testing.txt b/testing.txt
new file mode 100644
index 0000000..f416431
--- /dev/null
+++ b/testing.txt
@@ -0,0 +1,2 @@
+1
+adding this as well at 16:12h
