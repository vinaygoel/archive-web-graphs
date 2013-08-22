/*
 * Copyright 2013 Internet Archive
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you
 * may not use this file except in compliance with the License. You
 * may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

/* Input: An archival web graph - src, timestamp, {set of destinations}
 * Input: A 1-line plain text file (dummy) - can contain any content 
 * Output: A web graph without timestamp information with each node initialized with a PageRank of 1.
 * Output: The set of dangling nodes (nodes with no outlinks), the number of dangling nodes, 
 * the total number of nodes in the graph, 
 * the dangling factor which is used in distributing the rank from the dangling nodes equally amongst every other node in the graph
 */

%default I_ID_GRAPH_DIR 'congress109th-sample/id.graph.gz';
%default I_DUMMY_FILE 'congress109th-sample/dummy-file';
--I_DUMMY_FILE points to a plain txt file with a single line (the line can contain any text)
-- Workaround to ensure a non empty Relation in Pig

%default O_PR_ID_GRAPH_DIR 'congress109th-sample/pr-id.graph.gz';
%default O_PR_DANGLING_NODES 'congress109th-sample/pr-dangling-nodes.gz';
%default O_PR_GRAPH_NODES_COUNT 'congress109th-sample/pr-graph-nodes-count';
%default O_PR_DANGLING_NODES_COUNT 'congress109th-sample/pr-dangling-nodes-count';
%default O_PR_DANGLING_NODES_FACTOR 'congress109th-sample/pr-dangling-nodes-factor';

Graph = LOAD '$I_ID_GRAPH_DIR' as (src:chararray, timestamp:chararray, dests:{d:(dst:chararray)});
DanglingDummy = LOAD '$I_DUMMY_FILE' as (url: chararray);

Links = foreach Graph generate src, FLATTEN(dests) as dst;
Links = DISTINCT Links;

GraphWithoutTimestamps = GROUP Links by src;
Graph = FOREACH GraphWithoutTimestamps GENERATE group as src, Links.dst as dests;

SRC = DISTINCT(foreach Links generate src);
DST = DISTINCT(foreach Links generate dst);

AllNodes = union SRC, DST;
AllNodes = DISTINCT AllNodes;

Dangling = FILTER (join DST by dst left, SRC by src) by src is null;
DanglingNodes = foreach Dangling generate dst;

-- guaranteeing at least 1 record by combining with a dummy entry (DUMMY_FILE contains only one line)
DanglingNodesWithDummyGrouped = GROUP (UNION DanglingNodes,DanglingDummy) ALL;
DanglingNodesFactor = foreach DanglingNodesWithDummyGrouped generate COUNT($1) - 1;

GraphNodesCount = GROUP AllNodes ALL;
GraphNodesCount = FOREACH GraphNodesCount GENERATE COUNT($1);

-- NOTE: setting initial PR value to 1. This also means that DanglingNodesCount = DanglingNodesFactor
DanglingNodes = FOREACH DanglingNodes GENERATE dst, 1 as pagerank;
PRIDGraph = FOREACH Graph GENERATE src, 1 as pagerank, dests;

STORE PRIDGraph into '$O_PR_ID_GRAPH_DIR';
STORE DanglingNodes into '$O_PR_DANGLING_NODES';
STORE GraphNodesCount into '$O_PR_GRAPH_NODES_COUNT';
STORE DanglingNodesFactor into '$O_PR_DANGLING_NODES_COUNT';
STORE DanglingNodesFactor into '$O_PR_DANGLING_NODES_FACTOR';
