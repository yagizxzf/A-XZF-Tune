import {homedir} from 'node:os';
import {join} from 'node:path';
import {pathToFileURL} from 'node:url';
import {mkdirSync,writeFileSync} from 'node:fs';
const skill=process.env.ROBLOX_UI_MAKER_SKILL ?? join(homedir(),'.codex','skills','roblox-ui-maker');
const {launch,SETTLE}=await import(pathToFileURL(join(skill,'scripts','cdp.mjs')).href);
const browser=await launch(9335,1920,1080);
const checks={};
const tag=process.env.AXZF_UI_SHOT_PREFIX ?? '';
const shots=process.env.AXZF_UI_SHOT_DIR ?? 'ui/shots';
mkdirSync(shots,{recursive:true});
const pages=[
  ['hud','desktop',1280,720],
  ['hud_phone','mobile',844,390],
  ['states','states',1280,720],
  ['mobile_states','mobile-parked',844,390],
  ['mobile_help','mobile-help',844,390],
  ['mobile_portrait','mobile-portrait',390,750],
];
try {
  for(const [page,name,width,height] of pages) {
    await browser.size(width,height);
    await browser.goto(`http://127.0.0.1:8870/${page}.html`);
    const broken=await browser.eval(SETTLE); if(broken)throw Error('Broken images');
    checks[page]=await browser.eval('window.checkOverflow()');
    if(checks[page].overflow.length||checks[page].broken.length)throw Error(JSON.stringify(checks[page]));
    await browser.shot(join(shots,`${tag}${name}.png`),{x:0,y:0,width,height},1);
  }
  writeFileSync(process.env.AXZF_UI_CHECK_RECORD ?? 'evidence/ui-html-checks.json',JSON.stringify(checks,null,2)+'\n');
}finally{browser.close();}
