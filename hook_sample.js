exports.handler = async function (event, context, callback) {
    var params = {
    deploymentId: event.DeploymentId,
    lifecycleEventHookExecutionId: event.LifecycleEventHookExecutionId,
    status: 'Succeeded'
    };
    const response = await axios(http://lb-poc-app-766072423.us-east-1.elb.amazonaws.com);
    if (response.status != 200) {
    params.status = 'Failed';
    }
    await codedeploy.putLifecycleEventHookExecutionStatus(params).promise();
    }