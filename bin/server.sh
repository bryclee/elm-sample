if [ -z "$PORT" ]
then
	PORT=8080
fi
python -m SimpleHTTPServer $PORT
