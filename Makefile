### Helm push to ECR steps

CH_DIR = bitnami
# VERSION = ${TAG}
PACKAGED_CHART = ${TAG}.tgz
# Split the prefix (e.g., 'thanos') and the version (e.g., '2.3.4')
CHART := $(word 1, $(subst -, ,$(TAG)))  # This gets the version part (2.3.4)
VERSION := $(word 2, $(subst -, ,$(TAG)))  # This gets the prefix part (thanos)

push-chart:
	@echo "=== Helm login ==="
	@echo "=== 1${TAG}1 ==="
	@echo "=== 1${CH_DIR}1 ==="
	@echo "=== 1${PACKAGED_CHART}1 ==="
	@echo "=== 1${CHART}1 ==="
	@echo "=== 1${VERSION}1 ==="
	aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | helm3.6.3 registry login ${ECR_HOST} --username AWS --password-stdin --debug
	@echo "=== save chart ==="
	helm3.6.3 chart save ${CH_DIR}/${CHART}/ ${ECR_HOST}/dataos-base-charts:${TAG}
	@echo
	@echo "=== push chart ==="
	helm3.6.3 chart push ${ECR_HOST}/dataos-base-charts:${TAG}
	@echo
	@echo "=== logout of registry ==="
	helm3.6.3 registry logout ${ECR_HOST}

push-oci-chart:
	@echo
	echo "=== login to OCI registry ==="
	aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | helm3.14.0 registry login ${ECR_HOST} --username AWS --password-stdin --debug
	@echo
	@echo "=== package OCI chart ==="
	helm3.14.0 package ${CH_DIR}/${CHART}/ --version ${VERSION}
	@echo
	@echo "=== create repository ==="
	aws ecr describe-repositories --repository-names ${CHART} --no-cli-pager || aws ecr create-repository --repository-name ${CHART} --region $(AWS_DEFAULT_REGION) --no-cli-pager
	@echo
	@echo "=== push OCI chart ==="
	helm3.14.0 push ${PACKAGED_CHART} oci://$(ECR_HOST)
	@echo
	@echo "=== logout of registry ==="
	helm3.14.0 registry logout $(ECR_HOST)