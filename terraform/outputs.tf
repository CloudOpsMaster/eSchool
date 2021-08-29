output "eschool_srv_ip" {

    value = google_compute_instance.eschool-srv.network_interface.0.access_config.0.nat_ip

}