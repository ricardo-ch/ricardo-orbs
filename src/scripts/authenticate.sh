# Authenticate to GCP. All needed values have to be already present in CircleCi context or environment.
echo "${GCLOUD_SERVICE_KEY}" > "${HOME}"/gcp-key.json
gcloud auth activate-service-account --key-file "${HOME}"/gcp-key.json
gcloud --quiet config set project "${GOOGLE_PROJECT_ID}"
gcloud --quiet config set compute/zone "${GKE_COMPUTE_ZONE}"
gcloud --quiet container clusters get-credentials "${GKE_CLUSTER_NAME}" --zone "${GKE_COMPUTE_ZONE}"
kubectl config rename-context gke_"${GOOGLE_PROJECT_ID}"_"${GKE_COMPUTE_ZONE}"_"${GKE_CLUSTER_NAME}" "${GKE_CLUSTER_NAME}"
# If cluster is a "dev-banana" cluster, pull it again and rename it to "dev-cookie". Required for isopod as isopod uses "dev-cookie" context.
# other steps like port-forward will fail if the context is "dev-cookie".
if [ "${GKE_CLUSTER_NAME}" = "dev-banana" ]; then
  gcloud --quiet container clusters get-credentials "${GKE_CLUSTER_NAME}" --zone "${GKE_COMPUTE_ZONE}"
  kubectl config rename-context gke_"${GOOGLE_PROJECT_ID}"_"${GKE_COMPUTE_ZONE}"_"${GKE_CLUSTER_NAME}" "dev-cookie"
fi
