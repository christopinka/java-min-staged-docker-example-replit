FROM maven:3.6.3-jdk-11@sha256:66c14be1d6257c363f7e22ebc7bc656dbe7573fae7bbb271343f0ee4476a96d3 AS build
FROM adoptopenjdk:11-jre-hotspot@sha256:3f66ca022431afc9d51c6f57f51e77b1def0873cde6c4d2d93ac5fe10f6f30ff AS runtime
FROM debian:slim@sha256:c5c5200ff1e9c73ffbf188b4a67eb1c91531b644856b4aefe86a58d2f0cb05be