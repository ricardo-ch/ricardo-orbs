# Authenticate to GCP. All needed values have to be already present in CircleCi context or environment.
echo "${GCLOUD_SERVICE_KEY}" > "${HOME}"/gcp-key.json
export GOOGLE_APPLICATION_CREDENTIALS="${HOME}"/gcp-key.json
gcloud auth activate-service-account --key-file "${HOME}"/gcp-key.json
gcloud --quiet config set project "${GOOGLE_PROJECT_ID}"
gcloud --quiet config set compute/zone "${GKE_COMPUTE_ZONE}"
gcloud --quiet container clusters get-credentials "${GKE_CLUSTER_NAME}" --zone "${GKE_COMPUTE_ZONE}"
kubectl config rename-context gke_"${GOOGLE_PROJECT_ID}"_"${GKE_COMPUTE_ZONE}"_"${GKE_CLUSTER_NAME}" "${GKE_CLUSTER_NAME}"
