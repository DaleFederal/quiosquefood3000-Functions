const BigQuery = require('@google-cloud/bigquery').BigQuery
const instancia = new BigQuery()

async function criarTabela () {
    const dataset = instancia.dataset('QuiosqueFood')
    const [tabelas] = await dataset.getTables()
    const nomeTabela = 'customers'
    const tabelasEncontradas = tabelas.filter(function (tabelaAtual) {
        return tabelaAtual.id === nomeTabela
    })

    if (tabelasEncontradas.length > 0) {
        console.log('Essa tabela já existe!')
        return
    }

    const estrutura = [   
        {
            name: 'id',
            type: 'integer',
            mode: 'required'
        },     
        {
            name: 'nome',
            type: 'string',
            mode: 'required'
        },
        {
            name: 'email',
            type: 'string',
            mode: 'required'
        },
        {
            name: 'cpf',
            type: 'string',
            mode: 'required'
        }
    ]

    await dataset.createTable(nomeTabela, { schema: estrutura })
    console.log('A tabela foi criada com sucesso!')
}

criarTabela()