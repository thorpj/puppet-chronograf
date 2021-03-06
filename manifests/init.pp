class chronograf (
  String $bind_ip        = $chronograf::params::bind_ip,
  String $bind_port      = $chronograf::params::bind_port,
  String $version,
) inherits chronograf::params {


  case $chronograf::service_provider {
    "docker": {
      docker_image {$chronograf::service_image: }
    }
    default: {
      # $chronograf::packages.each |String $package_name, Hash $package| {
      #   package {$package_name:
      #     * => $package
      #   }
      # }

      $package_source_name = $::architecture ? {
        /386/   => "chronograf_${::chronograf::version}_i386.deb",
        default => "chronograf_${::chronograf::version}_amd64.deb",
      }

      $package_source = "https://dl.influxdata.com/chronograf/releases/${package_source_name}"
      include wget
      wget::fetch { 'chronograf':
        source      => $package_source,
        destination => "/tmp/${package_source_name}"
      }
      package { 'chronograf':
        ensure   => present,
        provider => 'dpkg',
        source   => "/tmp/${package_source_name}",
        require  => Wget::Fetch['chronograf'],
      }
    }
  }
    
    # case $package_source {
    #     default: {
    #         package { $package_name:
    #             ensure => installed,
    #         }
    #     }
    #     'web': {
    #         ensure_packages(['wget'])
    # 
    #         exec { 'Download Chronograf Package':
    #             command => "wget ${package_url} -P /tmp",
    #             creates => "/tmp/${source}",
    #             path    => '/usr/local/bin/:/bin/:/usr/bin',
    #             require => Package['wget'],
    #         }
    # 
    #         package { $package_name:
    #             ensure   => installed,
    #             provider => $provider,
    #             require  => Exec['Download Chronograf Package'],
    #             source   => "/tmp/${source}",
    #         }
    #     }
    # }
    # 
    # file { $config_file:
    #     ensure  => present,
    #     content => epp("${module_name}${config_file}.epp"),
    #     require => Package[$package_name],
    # }
    # 
    # service { $package_name:
    #     ensure    => running,
    #     #enable    => true, # TODO: Why is this broken...
    #     require   => Package[$package_name],
    #     subscribe => File[$config_file],
    # }

}
