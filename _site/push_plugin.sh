git branch -D master
echo "Master deleted"
git checkout -b master
echo "Checked out Master deleted"
git filter-branch --subdirectory-filter _site/ -f
echo "Applied filter branch"
git checkout source
echo "To SOurce again"
git push -f --all origin
echo "Pushed"