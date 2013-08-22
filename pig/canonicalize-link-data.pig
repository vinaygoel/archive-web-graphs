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

/* Input: Links And/Or Embeds (source, timestamp, destination, <optional>)
 * Output: SURT canonicalized links (canon-source, timestamp, canon-destination) 
 */

%default I_LINKS_DIR 'congress109th-sample/*-from-wats.gz/';
%default O_CANON_LINKS_DIR 'congress109th-sample/canonicalized-link-data.gz';

REGISTER lib/ia-hadoop-tools-jar-with-dependencies.jar;
REGISTER lib/pigtools.jar;
DEFINE SURTURL pigtools.SurtUrlKey();

Links = LOAD '$I_LINKS_DIR' as (src:chararray, timestamp:chararray, dst:chararray);

--filter out non-http links
Links = FILTER Links by (dst matches '^[hH][tT][tT][pP][sS]?[:]//.*');

-- canonicalize to SURT form
Links = FOREACH Links GENERATE SURTURL(src) as src, timestamp, SURTURL(dst) as dst;
Links = FILTER Links by dst is not null;

-- remove self links
Links = FILTER Links by src!=dst;

STORE Links into '$O_CANON_LINKS_DIR';
