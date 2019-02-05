## site.pp ##

node default {

include apache::mod::rewrite
class { '::composer':
  tag 			  =>  ['composer', 'build'],
  command_name => 'composer',
  target_dir   => '/usr/local/bin'
}
################################################
->
### Instala apache  ##########################
class { 'apache':
  tag 	 =>  ['apache', 'build'],
  default_vhost => false,
  mpm_module => 'prefork',
  service_manage => false,
}

apache::vhost{ "default.soltisam.com":
        tag 	 =>  ['apache', 'build'],
	port => '80',
	docroot => "/var/www/html/",
	manage_docroot => false,
	docroot_owner => 'www-data',
	docroot_group => 'www-data',

	directories => [
	 	{
  		path => "/var/www/html",
 		allow_override => 'All',
  		options => 'Indexes FollowSymLinks MultiViews',
	rewrites => [ { comment      => 'Permalink Rewrites',
                      rewrite_base => '/'
                    },
                    { rewrite_rule => [ '^index\.php$ - [L]' ]
                    },
                    { rewrite_cond => [ '%{REQUEST_FILENAME} !-f',
                                        '%{REQUEST_FILENAME} !-d',
                                      ],
                      rewrite_rule => [ '. /index.php [L]' ],
                    }
                  ],
 },
],
}
->
class { 'apache::mod::php':
        tag 	 =>  ['apache', 'build'],
    package_name => "php7.0",
    php_version  => "7.0",
  }
#############################################################
class { '::php::globals':
        tag 	 =>  ['php', 'build'],
  php_version => "7.0",
  config_root => "/etc/php/7.0",
}
->

class { '::php':
  tag 	 =>  ['php', 'build'],
 apache_config => true,
  ensure       => latest,
  manage_repos => true,
  composer     => false,
  pear         => true,
  fpm          => false,
settings   => {
    'PHP/max_execution_time'  => '90',
    'PHP/max_input_time'      => '300',
    'PHP/memory_limit'        => '512M',
    'PHP/post_max_size'       => '100M',
    'PHP/upload_max_filesize' => '100M',
    'Date/date.timezone'      => 'America/Caracas',
  },
extensions => {
    imagick  => {},
    xmlrpc   => {},
    mcrypt   => {},
    mysqlnd  => {},
    curl     => {},
    gd       => {},
    apcu     => {},
    zip      => {},
    intl     => {},
    mbstring => {},
  },

}
->
class { 'supervisor':
  tag 	 =>  ['supervisor', 'build'],
  package                   => true,
  service                   => false,
  supervisord_logfile       => '/var/log/supervisor/supervisord.log',
  supervisord_user          => 'root',
}
supervisor::program { 'apache':
  program_command      => 'puppet resource service apache2 ensure=running',
  program_process_name => 'apache',
  program_autostart    => true,
  program_autorestart  => false,
  program_user         => 'root',
  program_environment  => 'DEBUG=true',
}

}
