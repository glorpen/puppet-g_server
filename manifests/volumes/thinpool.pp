define g_server::volumes::thinpool(
  String $vg_name,
  String $size,
  String $lv_name = $title,
  Enum['present','absent'] $ensure = 'present',
  Optional[String] $metadata_size = undef
){
  lvm::logical_volume { $lv_name:
    ensure            => $ensure,
    volume_group      => $vg_name,
    size              => $size,
    mountpath_require => false,
    createfs          => false,
    thinpool          => true,
    poolmetadatasize  => $metadata_size
  }
}
