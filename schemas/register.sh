TOPIC=amr
SCHEMA_REGISTRY_HOST=schema-registry.kafka.svc.nbthpc.local
SCHEMA_REGISTRY_PORT=8081

for schemaType in key value;
do
  escapedAvroSchemaValue=$(cat ${schemaType}.avsc | awk '{ gsub("\"","\\\"",$0); print $0 }' | tr -d '\n')
  # echo $escapedAvroSchemaValue
  curl -X POST -H "Content-Type: application/vnd.schemaregistry.v1+json" \
    --data "{ \"schema\": \"${escapedAvroSchemaValue}\" }" \
    http://${SCHEMA_REGISTRY_HOST}:${SCHEMA_REGISTRY_PORT}/subjects/${TOPIC}-${schemaType}/versions
done