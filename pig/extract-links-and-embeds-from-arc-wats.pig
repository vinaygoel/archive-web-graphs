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

/* Input: WAT files generated from ARC files
 * Output: Links and Embeds from HTML pages (source, timestamp, destination, link type, and anchor text information)
 */

%default I_WATS_DIR 'congress109th-sample/wats/';
%default O_EMBEDS_DIR 'congress109th-sample/embeds-from-wats.gz/';
%default O_LINKS_DIR 'congress109th-sample/links-from-wats.gz/';

SET pig.splitCombination 'false';

REGISTER lib/ia-hadoop-tools-jar-with-dependencies.jar;
DEFINE URLRESOLVE org.archive.hadoop.func.URLResolverFunc();

-- load data from I_WATS_DIR:
Orig = LOAD '$I_WATS_DIR' USING org.archive.hadoop.ArchiveJSONViewLoader('Envelope.ARC-Header-Metadata.Target-URI','Envelope.ARC-Header-Metadata.Date','Envelope.Payload-Metadata.HTTP-Response-Metadata.HTML-Metadata.Head.Base','Envelope.Payload-Metadata.HTTP-Response-Metadata.HTML-Metadata.@Links.{url,path,text,alt}') as (src:chararray,timestamp:chararray,html_base:chararray,relative:chararray,path:chararray,text:chararray,alt:chararray);

-- discard lines without links
LinksOnly = FILTER Orig by relative != '';

-- Generate the resolved destination-URL
ResolvedLinks = FOREACH LinksOnly GENERATE src, timestamp, URLRESOLVE(src,html_base,relative) as dst, path, CONCAT(text,alt) as linktext;

EmbedLinks = FILTER ResolvedLinks by (path != 'A@/href') AND (path != 'FORM@/action');
OutLinks = FILTER ResolvedLinks by (path == 'A@/href') OR (path == 'FORM@/action');

EmbedLinks = DISTINCT EmbedLinks;
OutLinks = DISTINCT OutLinks;

STORE EmbedLinks INTO '$O_EMBEDS_DIR';
STORE OutLinks INTO '$O_LINKS_DIR';
