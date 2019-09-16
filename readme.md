# AWS Data Services Demonstrator - Initial Setup

This series of articles demonstrate some of the AWS Data Services capabilities. AWS areas covered as follows:
* **AWS CLI** to interact with AWS services
* **IAM** to set up users and assign policy documents to the users
* **Terraform** for Infrastructure as a Code (IaaC)
* **S3** buckets to store data
* **Firehose** capability to process high throughput and low latency data streams
* **Kinesis Data Gnerator** to produce random data to test Firehose
* **Athena** to define schema and query data uploaded to S3
* **Quicksight** to build dashboards against Athena
* **Sagemaker** to set-up Jupyer Lab, a data science workbench
* **Python** to programatically interact with AWS using packages such as: botos, pandas, numpy
* **Redshift** creating datawaerhouse and loading data from the streams
* **Lambda** transforming stream data using Lambda and Nodejs
* **CI/CD** Combining terraform with Travis CI

### Related Notebooks
* [00-Setup](https://github.com/satishrsdg/aws-finance-analytics-demo/blob/master/markdown/setup.md) 

* [01-Process S3 using python](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/process_s3_files.ipynb?flush_cache=true)

* [02-Visualization and Analytics](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/visualization_and_analytics.ipynb?flush_cache=true)

* [03-Risk Analytics](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/risk_analytics.ipynb?flush_cache=true)

* [04-Exploring Firehose](https://github.com/satishrsdg/aws-finance-analytics-demo/blob/master/markdown/exploring_kinesis_firehose.md)

* [05-Athena and Quicksights](https://github.com/satishrsdg/aws-finance-analytics-demo/blob/master/markdown/athena_quicksight.md)

* [06-Sagemaker to run the notebooks](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/sagemaker_jupyterlab.ipynb?flush_cache=true)

* [07_Transform stream data using Lambda](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/transform_lambda.ipynb?flush_cache=true)

* [08_Move data to Redshift using Glue](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/glue_redshift.ipynb?flush_cache=true)

* [09_CI/CD Terrform with Travis CI](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/integrating_terraform_travisci.ipynb?flush_cache=true)






