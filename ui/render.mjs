import {homedir} from 'node:os';
import {join} from 'node:path';
import {pathToFileURL} from 'node:url';
import {writeFileSync} from 'node:fs';
const skill=process.env.ROBLOX_UI_MAKER_SKILL ?? join(homedir(),'.codex','skills','roblox-ui-maker');
const {launch,SETTLE}=await import(pathToFileURL(join(skill,'scripts','cdp.mjs')).href);
const browser=await launch(9335,1920,1080);
const checks={};
try {
  for(const [page,name] of [['hud','desktop'],['hud_phone','mobile'],['states','states']]) {
    await browser.goto(`http://127.0.0.1:8870/${page}.html?raw`);
    const broken=await browser.eval(SETTLE); if(broken)throw Error('Broken images');
    checks[page]=await browser.eval('window.checkOverflow()');
    if(checks[page].overflow.length||checks[page].broken.length)throw Error(JSON.stringify(checks[page]));
    await browser.shot(`ui/shots/${name}.png`,{x:0,y:0,width:1920,height:1080},1);
  }
  writeFileSync('evidence/v3-html-checks.json',JSON.stringify(checks,null,2)+'\n');
}finally{browser.close();}
