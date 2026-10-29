// Optional UI authoring dependency: npm install --prefix .tools/svg @resvg/resvg-js
// Source art is Lucide ISC/Feather MIT; retain licenses/Lucide-LICENSE.txt.
import fs from 'node:fs';
import {createRequire} from 'node:module';
const require=createRequire(import.meta.url);
const {Resvg}=require('../.tools/svg/node_modules/@resvg/resvg-js');
fs.mkdirSync('ui/icon-pack/png',{recursive:true});
for(const file of fs.readdirSync('ui/icon-pack/lucide').filter(f=>f.endsWith('.svg'))){
  const svg=fs.readFileSync('ui/icon-pack/lucide/'+file,'utf8').replaceAll('currentColor','#ffffff');
  fs.writeFileSync('ui/icon-pack/png/'+file.replace('.svg','.png'),new Resvg(svg,{fitTo:{mode:'width',value:128}}).render().asPng());
}
