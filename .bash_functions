cls ()
{
  tput reset
}

disk_vol ()
{
  df -h .
}

disk_cd ()
{
  du -h --max-depth=1 | sort -hr
  ls -an
}
