# Current date, time, and seconds since epoch
# 0 = 4-digit year
# 1 = 2-digit year
# 2 = 2-digit month
# 3 = 2-digit day
# 4 = 2-digit hour
# 5 = 2-digit minute
# 6 = 2-digit second
# 7 = Epoch (seconds since 1970-01-01_00:00:00)
# Array index                                            0  1  2  3  4  5  6  7
set datetime_arr [clock format [clock seconds] -format {%Y %y %m %d %H %M %S %s}]
 
# Get the datecode in the yy-mm-dd-HH format
set datecode [lindex $datetime_arr 1][lindex $datetime_arr 2][lindex $datetime_arr 3][lindex $datetime_arr 4]
set datecode_epoch [lindex $datetime_arr 7]

# Show this in the log
puts DATECODE=$datecode_epoch
 
# Get the git hashtag for this project
set curr_dir [pwd]
set proj_dir [get_property DIRECTORY [current_project]]
cd $proj_dir
set git_hash [exec git rev-parse --short=8 HEAD]

#figure out how to properly determine if git repo is "dirty"
#set git_repo_dirty [exec git diff]
#temporary placeholder
set git_repo_dirty 0


# Show this in the log
puts GITHASHCODE=$git_hash
puts GITREPODIRTY=$git_repo_dirty
 
# Set the generics
#set_property generic {C_DATE_CODE=32'h$datecode_epoch C_GITHASH_CODE=32'h$git_hash} [current_fileset]
