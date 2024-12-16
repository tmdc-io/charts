### Helm push to ECR steps

CH_DIR = bitnami
# VERSION = ${TAG}
PACKAGED_CHART = ${TAG}.tgz
CHART := $(strip $(word 1, $(subst -, ,$(TAG))))
VERSION := $(subst $(word 1,$(subst -, ,$(TAG)))-, ,$(TAG))

push-chart:
	@echo "=== Helm login ==="
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
	@echo "=== update dependencies ==="
	helm3.14.0 dependency update ${CH_DIR}/${CHART}/
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