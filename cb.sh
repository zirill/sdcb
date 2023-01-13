#!/bin/sh

fnTestDOAMIN() {
  if [ -z "$1" ]; then
    echo "empty is domain"
    exit 1
  fi
}

fnADD() {
  echo "add domain: $1 "
  docker run -it --rm --name cb \
              -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
              certbot/certbot certonly --agree-tos --register-unsafely-without-email --webroot -w /var/lib/letsencrypt/ -d "$1"
#--expand
}

fnDEL() {
  echo "del domain: $1 "
  docker run -it --rm --name cb \
              -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
              certbot/certbot delete --cert-name "$1"
}

fnRNEW() {
  echo "renew domain "
  docker run -it --rm --name cb \
              -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
              certbot/certbot renew --dry-run

SNG=$(nginx -t 2>&1)
SOK="syntax is ok"
  if [ -z "${SNG##*$SOK*}" ] && [ -n "$SNG" ]; then
          nginx -s reload
  else
          echo "$SNG"
  fi
}

fnLIST() {
  echo "get list domain "
  docker run -it --rm --name cb \
              -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
              certbot/certbot certificates
}

APSH=$(realpath -s "$0")
CCMD="/bin/sh $APSH n"
CJOB="0 6 * * 0 $CCMD"

fnCronADD() {
  echo "add to cron"
  ( crontab -l | grep -v -F "$CCMD" ; echo "$CJOB" ) | crontab -
}

fnCronRMOVE() {
  echo "remove from cron"
  ( crontab -l | grep -v -F "$CCMD" ) | crontab -
}

fnHELP() {
  echo "
HELP script command:

  a - add domain
    Example: ./cb.sh a mydomain.com,www.mydomain.com

  d - delete domain
    Example: ./cb.sh d www.mydomain.com

  n - renew all domain
    Example: ./cb.sh n

  l - show all domain


  c - add to cron this file every week

  r - remove from cron this file every week


  h - this text

"

}

case "$1" in
    "a")
        fnTestDOAMIN $2
        fnADD $2
        ;;
    "d")
        fnTestDOAMIN $2
        fnDEL $2
        ;;
    "n")
        fnRNEW
        ;;
    "l")
        fnLIST
        ;;
    "c")
        fnCronADD
        ;;
    "r")
        fnCronRMOVE
        ;;
    "h")
        fnHELP
        ;;
    *)
        echo "empty is command"
        exit 1
        ;;
esac
