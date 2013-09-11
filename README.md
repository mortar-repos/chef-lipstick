Lipstick Cookbook
=================
The lipstick cookbook installs and configures the Lipstick job visualization server from Netflix.


Requirements
------------
This cookbook has only been tested on CentOS 6, but should work on other Linux systems.

- `java` - Needed to build the jar files
- `mysql` - Needed if you are running the demo recipe
- `tomcat` - To hold the web application


Attributes
----------

#### lipstick::default
<table>
  <tr>
    <th>Key</th><th>Type</th><th>Description</th><th>Default</th>
  </tr>
  <tr>
    <td><tt>['lipstick']['git_checkout_directory']</tt>
    </td><td>String</td>
    <td>Directory to stage the Lipstick source code</td>
    <td><tt>/tmp/lipstick</tt></td>
  </tr>
  <tr>
    <td><tt>['lipstick']['git_repo']</tt>
    </td><td>String</td>
    <td>Lipstick git repo, change to run your own fork</td>
    <td><tt>https://github.com/Netflix/Lipstick.git</tt></td>
  </tr>
  <tr>
    <td><tt>['lipstick']['git_ref']</tt>
    </td><td>String</td>
    <td>Default branch/revision/ref in the git repo to checkout</td>
    <td><tt>master</tt></td>
  </tr>
</table>

Usage
-----
#### lipstick::default
Installs the Lipstick Server and a MySQL server.  This is the simpliest way to deploy, though less flexible.

#### lipstick::server
Installs the Lipstick Server. If you are running a MySQL server on another host, make sure you set the
following attributes for this node so it knows what database to connect to:

    node['mysql']['server_root_password']
    node['mysql']['bind_address']
    node['mysql']['port']

#### lipstick::mysql
Installs MySQL and creates the necessary database that Lipstick expects.

#### lipstick::demo
Installs the all components necessary to run Lipstick and Hadoop on a single machine. This is useful for trying out Lipstick but should not be used in a production environment.  The pseudo_hadoop and centos_patch recipes are used here, and don't serve much in other contexts.

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License
-------------------
See LICENSE
