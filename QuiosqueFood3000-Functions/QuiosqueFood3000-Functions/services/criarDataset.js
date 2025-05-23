const BigQuery = require('@google-cloud/bigquery').BigQuery
const instancia = new BigQuery()

async function criarDataset (params) {
    const datasets = await instancia.getDatasets()
    const nomeDataset = 'QuiosqueFood'
    const datasetsFiltrados = datasets.filter(function(datasetAtual){
        return datasetAtual.id === nomeDataset
    })

    if(datasetsFiltrados.length>0){
        console.log('Dataset já criado')
        return
    }

    await instancia.createDataset(nomeDataset)
    console.log('Dataset criado com sucesso')
}

criarDataset()