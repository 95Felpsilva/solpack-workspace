# Programação de Entrega / Programação de OP - Documentação Técnica (SOPCPC01)

Este documento registra todo o histórico de análises, regras de negócio, problemas identificados e evoluções técnicas implementadas na rotina de **Programação de OP (SOPCPC01.prw)** e componentes integrados em **20/10/2026**.

---

## 1. Visão Geral da Rotina

A rotina **[SOPCPC01.prw](file:///c:/Users/95fel/OneDrive/Documents/_Clientes/_SOLPACK/Fontes/SOPCPC01.prw)** é responsável pelo sequenciamento, dimensionamento de datas e manutenção das Ordens de Produção na tabela customizada **ZO2** (Programação de Produção por Tear e Setor).

### Tabelas Principais Integradas:
* **ZO2:** Tabela de Programação do PCP (Filial, OP, Tear, Setor, Produto, Quantidade, Produzido, Datas Inicial/Final, Prioridade, Produção Diária, etc.).
* **SC2:** Cadastro de Ordens de Produção (`C2_NUM`, `C2_ITEM`, `C2_SEQUEN`, `C2_QUANT`, `C2_QUJE`, `C2_DATPRI`, `C2_DATPRF`, `C2_ZZSETOR`, `C2_ZZTEAR`, `C2_ZRECORI`).
* **SB1:** Cadastro de Produtos (`B1_COD`, `B1_XTPPROD`, `B1_QE`, `B1_CONV`, `B1_UM`).
* **SH1:** Cadastro de Recursos / Teares (`H1_CODIGO`, `H1_DESCRI`, `H1_ZZTPTEA`, `H1_ZZSETOR`).
* **SH6:** Apontamentos de Produção (`H6_OP`, `H6_DATAINI`, `H6_HORAINI`, `H6_DATAFIN`, `H6_HORAFIN`, `H6_QTDPROD`).
* **CZG:** Ficha Técnica / Atributos do Produto (Comprimento de Tela, Largura, Caída, Ponto, etc.).

---

## 2. Detalhamento das Evoluções Realizadas

### 2.1. Regra de Conversão de Quantidade da OP (`ZO2_QUANT`)
* **Situação:** Na rotina de Programação de OP, a quantidade gerada em `ZO2_QUANT` para o setor **G0** (Extrusão / Monofilamento) não deve sofrer conversão ou divisão por `B1_QE`.
* **Regra Aplicada nas funções [PCP01GeraProgramacao](file:///c:/Users/95fel/OneDrive/Documents/_Clientes/_SOLPACK/Fontes/SOPCPC01.prw#L932) e [PCP01AtualizaProgramacao](file:///c:/Users/95fel/OneDrive/Documents/_Clientes/_SOLPACK/Fontes/SOPCPC01.prw#L1093):**
  ```advpl
  If (cAliasQry)->B1_XTPPROD <> "2" .And. Alltrim((cAliasQry)->C2_ZZSETOR) <> "G0"
      nQuantOP := IIF(!Empty((cAliasQry)->B1_QE), ( (cAliasQry)->C2_QUANT / (cAliasQry)->B1_QE ), (cAliasQry)->C2_QUANT )
      nKgProd  := nQuantOP * IIF(!Empty((cAliasQry)->B1_QE), (cAliasQry)->B1_QE, 1 ) * (cAliasQry)->B1_CONV
  Else
      nQuantOP := (cAliasQry)->C2_QUANT
      nKgProd  := nQuantOP * (cAliasQry)->B1_CONV
  EndIf
  ```
* **Resultado:** Quando o setor for `G0`, a quantidade da OP é gravada exatamente conforme `SC2->C2_QUANT` (sem divisão).

---

### 2.2. Replicação de KG/HORA e Eficiência para Demais OPs do Mesmo Recurso
* **Situação:** Ao preencher os campos `_KGHREX` (KG/Hora da Extrusora) e `_EFICIE` (% Eficiência) no modelo MVC de uma OP, os valores precisavam ser replicados automaticamente para todas as OPs em aberto (status 1 e 2) daquele mesmo recurso/tear.
* **Ajuste na Função [alteraRPMOutrasOPs](file:///c:/Users/95fel/OneDrive/Documents/_Clientes/_SOLPACK/Fontes/SOPCPC01.prw#L293):**
  * Disparada no `saveForm` após o commit do modelo MVC.
  * Localiza todas as OPs em aberto do mesmo tear e setor e atualiza `_KGHREX`, `_EFICIE` e recalcula `_PRODIA := nKgHrEx * 24 * ( nEficie / 100 )`.
  * **Correção de Bug Crítico:** Removida a linha `(cAliasForm)->(dbCloseArea())` que estava dentro do laço `While !(cAlias)->(Eof())`. Anteriormente, a tabela `ZO2` era fechada logo após a primeira OP, impedindo que as demais ordens da fila fossem posicionadas e atualizadas.

---

### 2.3. Reprogramação de Datas - Projeção de Término no Passado
* **Problema Identificado:** 
  * Exemplo real: OP `05830101001` (Tear 23, Setor G1), com QTD OP = 22, QTD PROD = 21 (saldo = 1 peça), 1º apontamento em 11/09/2026.
  * O cálculo pegava a data do 1º apontamento (`11/09/2026`) como início do cálculo. Como o saldo restante (1 peça) cabia em 1 dia de produção (`nCapDiaria = 1.2853`), o sistema cravava a data final como `11/09/2026`.
  * Com isso, uma OP ainda em aberto ficava com data final no passado, e a OP seguinte era programada concorrentemente para a data atual, gerando sobreposição indevida no mesmo tear.
* **Solução Implementada na Função [processaProgramacao](file:///c:/Users/95fel/OneDrive/Documents/_Clientes/_SOLPACK/Fontes/SOPCPC01.prw#L416):**
  * O campo `ZO2_DATPRI` **mantém** a data real do primeiro apontamento (`dPrimeiroAp`), preservando o histórico de quando a ordem começou a ser produzida em fábrica.
  * A variável base para cálculo do saldo restante a produzir (`dCalcData`) passa a ser ajustada para a data atual (`Date()`) sempre que houver saldo faltante e a data base estiver no passado:
    ```advpl
    // Se a OP tem saldo a produzir e a data base ficou no passado,
    // o saldo restante DEVE ser programado a partir de HOJE!
    If nRest > 0 .And. dCalcData < Date()
        dCalcData := Date()
    EndIf
    ```
  * Adicionada validação de segurança: se a OP ainda possui saldo a produzir (`nQtdFalt > 0`), a sua data final não pode ser menor que `Date()`.

---

### 2.4. Programação em Paralelo de OPs com a Mesma Prioridade
* **Situação / Cenário da Planilha `sopcpc01.xlsx`:**
  * Em teares têxteis (como o Tear Karl Mayer 02), ordens com a **mesma prioridade** são tecidas **em paralelo** ao longo da largura útil do tear (exemplo: uma tela de 2.00m de largura e outra tela de 1.50m produzidas simultaneamente).
  * Anteriormente, a rotina tratava cada registro sequencialmente, fazendo com que uma OP de mesma prioridade iniciasse somente após o término da outra, dobrando o tempo de máquina e jogando as prioridades 3, 4 e 5 para o final de dezembro e janeiro de 2027.
* **Nova Regra Implementada em [processaProgramacao](file:///c:/Users/95fel/OneDrive/Documents/_Clientes/_SOLPACK/Fontes/SOPCPC01.prw#L416):**
  1. **Agrupamento por Prioridade:** O laço identifica a prioridade da OP (`cPrior`).
  2. **Mesma Prioridade (`cPrior == cPriorAnt`):**
     * Todas as ordens da mesma prioridade recebem a **mesma data inicial** (`dDataIni := dIniPrior`).
     * Cada ordem calcula seus próprios dias de produção a partir de `dIniPrior` usando sua própria capacidade diária (`(cAlias)->PRODIARIA`).
     * Rastreia-se a maior data de término do grupo:
       ```advpl
       If Empty(dMaxFimPrior) .Or. dDataFim > dMaxFimPrior
           dMaxFimPrior := dDataFim
       EndIf
       ```
  3. **Mudança de Prioridade (`cPrior != cPriorAnt`):**
     * O novo lote de prioridade inicia na **maior data final** do lote de prioridade anterior:
       ```advpl
       dIniPrior    := dMaxFimPrior
       cPriorAnt    := cPrior
       dMaxFimPrior := dIniPrior
       ```
     * Garante que o tear só avança para o próximo setup/prioridade quando todas as ordens paralelas daquele grupo estiverem concluídas.
  4. **Correção do `dbCloseArea()`:**
     * Removido o fechamento da tabela `ZO2` de dentro do laço `While`. A tabela permanece aberta para gravar todas as ordens consecutivamente.

---

### 2.5. Ajustes no App de Apontamento de Produção (MOD2)
* **Objetivo:** Trazer automaticamente a Hora Inicial preenchida no aplicativo ao abrir um novo apontamento para uma OP que já possui apontamentos anteriores.
* **Componentes Atualizados:**
  1. **[ApontamentoMOD2.tlpp](file:///c:/Users/95fel/OneDrive/Documents/_Clientes/_SOLPACK/Fontes/Integração%20-%20PO%20UI/APIs/ApontamentoMOD2.tlpp):**
     * Ajustada a query da classe REST para incluir subquery trazendo o campo `H6_HORAFIN` do último apontamento registrado no `SH6` daquela OP (`HORA_FIM`).
  2. **[machine-production.component.ts](file:///c:/Users/95fel/OneDrive/Documents/_Clientes/_SOLPACK/Fontes/new-app-project/src/app/machine-production/machine-production.component.ts):**
     * Adicionado o repasse do campo `hora_fim` retornado pela API para a navegação e estado da tela de apontamento.
  3. **[production-input-mod2.component.ts](file:///c:/Users/95fel/OneDrive/Documents/_Clientes/_SOLPACK/Fontes/new-app-project/src/app/production-input-mod2/production-input-mod2.component.ts):**
     * Carregamento do valor no formulário para preencher a Hora Inicial com o horário de término do apontamento anterior.

---

## 3. Resumo dos Fontes e Arquivos Alterados

| Arquivo | Localização | Alterações Principais |
| :--- | :--- | :--- |
| [SOPCPC01.prw](file:///c:/Users/95fel/OneDrive/Documents/_Clientes/_SOLPACK/Fontes/SOPCPC01.prw) | `Fontes/` | Cálculo paralelo por prioridade, ajuste de data base para `Date()`, remoção de `dbCloseArea` em loops, regra do setor G0. |
| [ApontamentoMOD2.tlpp](file:///c:/Users/95fel/OneDrive/Documents/_Clientes/_SOLPACK/Fontes/Integração%20-%20PO%20UI/APIs/ApontamentoMOD2.tlpp) | `Fontes/Integração - PO UI/APIs/` | Retorno do campo `H6_HORAFIN` do último apontamento da OP como `HORA_FIM`. |
| [machine-production.component.ts](file:///c:/Users/95fel/OneDrive/Documents/_Clientes/_SOLPACK/Fontes/new-app-project/src/app/machine-production/machine-production.component.ts) | `Fontes/new-app-project/src/app/` | Repasse de `hora_fim` para a tela de input. |
| [production-input-mod2.component.ts](file:///c:/Users/95fel/OneDrive/Documents/_Clientes/_SOLPACK/Fontes/new-app-project/src/app/production-input-mod2/production-input-mod2.component.ts) | `Fontes/new-app-project/src/app/` | Inicialização automática da Hora Inicial com a Hora Final anterior. |
| [agenda-20102026.sql](file:///c:/Users/95fel/OneDrive/Documents/_Clientes/_SOLPACK/agenda-20102026.sql) | `_SOLPACK/` | Registro formal das atividades de 20/10/2026. |
| [sopcpc01.xlsx](file:///c:/Users/95fel/OneDrive/Documents/_Clientes/_SOLPACK/Fontes/sopcpc01.xlsx) | `Fontes/` | Planilha de referência fornecida pelo cliente com o comparativo de datas calculadas vs. manuais. |

---

*Documento gerado em 20/10/2026 para fins de rastreabilidade e histórico de desenvolvimento.*
