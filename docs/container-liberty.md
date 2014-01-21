# Liberty Container
You can run a web application or Liberty server package in the Liberty Container.

<table border>
  <tr>
    <td><strong>Detection Criterion</strong></td><td>Existence of a <tt>server.xml</tt> or <tt>WEB-INF/</tt> folder in the application directory</td>
  </tr>
  <tr>
    <td><strong>Tags</strong></td><td><tt>liberty-&lang;version&rang;</tt></td>
  </tr>
</table>
Tags are printed to standard output by the Buildpack `detect` script.

To specify the [Spring profiles][], set the [`SPRING_PROFILES_ACTIVE`][SPRING_PROFILES_ACTIVE] environment variable.  This is automatically detected and used by Spring.

## Configuration
For general information on configuring the Buildpack, refer to [Configuration and Extension][Configuration_and_Extension].

You can modify the [`config/liberty.yml`][liberty.yml] file to configure the container. The container uses the [`Repository` utility support][repositories] and it supports the [version syntax][version_syntax].


| Name | Description
| ---- | -----------
|`repository_root`| The URL of the Liberty repository index ([details][repositories])  
|`version`| The version of the Liberty profile. You can find the candidate versions [here][liberty.yml].
|`minify`| Boolean indicating whether the Liberty server should be minified. Minification potentially reduces the size of the deployed Liberty server because only the requested features are included, but it might result in longer push times. The default value is `false`.

The `minify` option can be overridden on a per-application basis by specifying a `minify` environment variable in the `manifest.yml` for the application. For example:

```
  env:
    minify: true
```

[Configuration_and_Extension]: ../README.md#Configuration-and-Extension
[liberty.yml]: ../config/liberty.yml
[repositories]: util-repositories.md
[Spring profiles]:http://blog.springsource.com/2011/02/14/spring-3-1-m1-introducing-profile/
[SPRING_PROFILES_ACTIVE]: http://static.springsource.org/spring/docs/3.1.x/javadoc-api/org/springframework/core/env/AbstractEnvironment.html#ACTIVE_PROFILES_PROPERTY_NAME
[version_syntax]: util-repositories.md#version-syntax-and-ordering