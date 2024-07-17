trivy() {
    local image_name=$1
    local report_name="reporte_$(echo ${image_name} | tr '/:.' '_').txt"

    docker-compose run --rm trivy image ${image_name} > ${report_name}

    echo "Se ha generado el reporte: ${report_name}"
}