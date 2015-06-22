# DNService
The server module of [`DNSManager`](../../../DNSManager), this provide Domain Name Service and support base function like [A, CNAME, MX, NS, SOA]

and use `Rake` to manage process.

# Description
This `DNService` will load record from database at first, and cache it forever until make a reload query to `DNService`.
When send a reload query to `DNService`, it'll compare the `question` is same as `reload-key``(ENV['DNS_RELOAD_KEY'])` to reload records from database.

# Install

## 1. Install Ruby (Ubuntu)
```bash
sudo apt-get install -y curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev
mkdir /tmp/ruby && cd /tmp/ruby
curl -L --progress http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.1.tar.gz | tar xz
cd ruby-2.2.1
./configure --disable-install-rdoc
make
sudo make install
sudo gem install bundler --no-ri --no-rdoc
```

## 2. Setting DNService

Change the parameter or set environment variable to your own, see [config/dnservice.yml](config/dnservice.yml)

```yaml
bind-ip: DNService's IP
bind-port: DNService's Port
ttl:  Record's TTL
recursive-query: Use forwarder to handle unhosted domain?
forwarder-ip: Forwarder's IP
forwarder-port: Forwarder's Port
db-connection-string: Record Database connection string
reload-key: Use to force reload record from database
```

## 3. Start Service
```bash
$ rake start    # DNService | Start Service

#Action list
rake start    # DNService | Start Service
rake reload   # DNService | Reload Record
rake reset    # DNService | Reset
rake restart  # DNService | Restart Service
rake run      # DNService | Run Application (Not Daemon)
rake status   # DNService | Status
rake stop     # DNService | Stop Service
```
# Example

## Reload query
Method 1. Make a reload query to local `DNService`

```ruby
Resolv::DNS.open(nameserver_port: [['127.0.0.1', 5300]])
	.getresources('thisisreloadkey', Resolv::DNS::Resource::IN::TXT)
```

Method 2. Use `Rake`

```bash
$ rake reload
```

# Contributor:

1. Yeti Sno (yeti@yetiz.org)
2. Cake Ant \[Gloria Lin\] (ant@yetiz.org)
