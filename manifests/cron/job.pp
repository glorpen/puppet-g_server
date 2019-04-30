define g_server::cron::job(
    String $ensure = 'present',
    #command => undef
    String $minute = '*',
    String $hour = '*',
    String $date = '*',
    String $month = '*',
    String $weekday = '*',
    Optional[String] $special = undef,
    String $user = 'root',
    Hash[String, String] $environment = {},
    Optional[String] $description = undef,
    Hash[String, Any] $vars = {},
    Optional[String] $source = undef,
    Optional[String] $template_content = undef,
    Optional[String] $template_source = undef,
){

  include ::stdlib

  if ($source != undef) {
    $_content = undef
    $_source = $source
  } else {
    if ($template_content != undef) {
      $_content = inline_epp($template_content, $vars)
    } else {
      $_content = epp($template_source, $vars)
    }
    $_source = undef
  }

  $safe_name = regsubst($name, /[^0-9A-Za-z]+/, '-')
  $job_file = "/usr/local/bin/cron-job-${safe_name}"

  file { $job_file:
    ensure  => $ensure,
    source  => $_source,
    content => $_content,
    owner   => $user,
    mode    => 'u=rwx,og='
  }

  ::cron::job { $name:
    minute      => $minute,
    hour        => $hour,
    date        => $date,
    month       => $month,
    weekday     => $weekday,
    special     => $special,
    user        => $user,
    environment => $environment.map |$k, $v| {
      $_safe_v = shell_escape($v)
      "${k}=${_safe_v}"
    },
    description => $description,
    command     => $job_file
  }

  if ($ensure == 'present') {
    File[$job_file]->Cron::Job[$name]
  } else {
    Cron::Job[$name]->File[$job_file]
  }

}