ENV["REDISTOGO_URL"] ||= "redis://redistogo:9a244e06e953d492b93ff5bdbe0d107e@perch.redistogo.com:9187/"

uri = URI.parse(ENV["REDISTOGO_URL"])
Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
