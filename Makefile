### Helm push to ECR steps

CH_DIR = bitnami
THANOS_DIR = thanos
REDIS_DIR = redis
# VERSION = ${TAG}
PACKAGED_CHART = ${TAG}.tgz
THANOS_VERSION := $(patsubst thanos-%, %, $(TAG))
REDIS_VERSION := $(patsubst redis-%, %, $(TAG))

push-thanos-chart:
	@echo "=== Helm login ==="
	aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | helm3.6.3 registry login ${ECR_HOST} --username AWS --password-stdin --debug
	@echo "=== save chart ==="
	helm3.6.3 chart save ${CH_DIR}/${THANOS_DIR}/ ${ECR_HOST}/dataos-base-charts:${TAG}
	@echo
	@echo "=== push chart ==="
	helm3.6.3 chart push ${ECR_HOST}/dataos-base-charts:${TAG}
	@echo
	@echo "=== logout of registry ==="
	helm3.6.3 registry logout ${ECR_HOST}

push-thanos-oci-chart:
	@echo
	echo "=== login to OCI registry ==="
	aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | helm3.14.0 registry login ${ECR_HOST} --username AWS --password-stdin --debug
	@echo
	@echo "=== package OCI chart ==="
	helm3.14.0 package ${CH_DIR}/${THANOS_DIR}/ --version ${THANOS_VERSION}
	@echo
	@echo "=== create repository ==="
	aws ecr describe-repositories --repository-names ${THANOS_DIR} --no-cli-pager || aws ecr create-repository --repository-name ${THANOS_DIR} --region $(AWS_DEFAULT_REGION) --no-cli-pager
	@echo
	@echo "=== push OCI chart ==="
	helm3.14.0 push ${PACKAGED_CHART} oci://$(ECR_HOST)
	@echo
	@echo "=== logout of registry ==="
	helm3.14.0 registry logout $(ECR_HOST)

push-redis-chart:
	@echo "=== Helm login ==="
	aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | helm3.6.3 registry login ${ECR_HOST} --username AWS --password-stdin --debug
	@echo "=== save chart ==="
	helm3.6.3 chart save ${CH_DIR}/${REDIS_DIR}/ ${ECR_HOST}/dataos-base-charts:${TAG}
	@echo
	@echo "=== push chart ==="
	helm3.6.3 chart push ${ECR_HOST}/dataos-base-charts:${TAG}
	@echo
	@echo "=== logout of registry ==="
	helm3.6.3 registry logout ${ECR_HOST}

push-redis-oci-chart:
	@echo
	echo "=== login to OCI registry ==="
	aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | helm3.14.0 registry login ${ECR_HOST} --username AWS --password-stdin --debug
	@echo
	@echo "=== package OCI chart ==="
	helm3.14.0 package ${CH_DIR}/${REDIS_DIR}/ --version ${REDIS_VERSION}
	@echo
	@echo "=== create repository ==="
	aws ecr describe-repositories --repository-names ${REDIS_DIR} --no-cli-pager || aws ecr create-repository --repository-name ${REDIS_DIR} --region $(AWS_DEFAULT_REGION) --no-cli-pager
	@echo
	@echo "=== push OCI chart ==="
	helm3.14.0 push ${PACKAGED_CHART} oci://$(ECR_HOST)
	@echo
	@echo "=== logout of registry ==="
	helm3.14.0 registry logout $(ECR_HOST)