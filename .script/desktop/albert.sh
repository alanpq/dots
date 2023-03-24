while test $# != 0
do
  case "$1" in
    -r|--reload) reload=1 ;;
  esac
  shift
done

if [[ $reload -eq 1 ]]; then
  echo "Reloading..."
  killall albert
  albert &
else
  pidof albert || albert &
fi
