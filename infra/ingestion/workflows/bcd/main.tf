# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "google_service_account" "service_account" {
  account_id   = "bcd-${var.env_id}"
  provider     = google.internal_project
  display_name = "BCD Workflow service account for ${var.env_id}"
}

resource "google_workflows_workflow" "workflow" {
  count           = length(var.regions)
  provider        = google.internal_project
  name            = "${var.env_id}-bcd-${var.regions[count.index]}"
  region          = var.regions[count.index]
  description     = "BCD Workflow. Env id: ${var.env_id}"
  service_account = google_service_account.service_account.id
  source_contents = templatefile(
    "${path.root}/../workflows/bcd/workflows.yaml.tftpl",
    {
      project_id   = google_cloud_run_v2_job.bcd[count.index].project
      job_name     = google_cloud_run_v2_job.bcd[count.index].name
      job_location = google_cloud_run_v2_job.bcd[count.index].location
    }
  )
}
