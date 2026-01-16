/**
 * Lambda Handler Function
 * Este handler procesa eventos de Lambda y retorna una respuesta simple.
 * Usa logging estructurado en JSON para facilitar análisis en CloudWatch Logs.
 */
exports.handler = async (event, context) => {
  // Log estructurado en formato JSON - mejor práctica para CloudWatch Insights
  console.log(JSON.stringify({
    message: 'Lambda invoked successfully',
    event: event,
    timestamp: new Date().toISOString(),
    requestId: context.requestId
  }));

  // Respuesta simple con statusCode 200 y body "ok"
  return {
    statusCode: 200,
    body: 'ok'
  };
};
