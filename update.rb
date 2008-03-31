#restart the server

`/home/consti/opt/bin/git pull origin master`

`ps -x`.each do |line|
  if line.include? 'mongrel'
    pid = line.strip.split(" ").first
    break
  end
end

`kill #{pid}` if pid`

`export GEM_PATH=~/gems`
`./autostart.cgi`