"""Build local art-inclusive scene from a geometry-only Studio export. Never publish its art."""
import json
from pathlib import Path
import xml.etree.ElementTree as ET
import build

ROOT = Path(__file__).resolve().parents[1]


def export():
    rows = json.loads((ROOT/"evidence/imported-geometry.json").read_text(encoding="utf-8"))
    if isinstance(rows, str):
        rows = json.loads(rows)
    if isinstance(rows, dict):
        rows = [rows[str(i)] for i in range(1, len(rows)+1)]
    tree = ET.fromstring(build.make_xml(build.sources()))
    workspace = ET.SubElement(tree, "Item", {"class":"Workspace", "referent":"LocalWorkspace"})
    ET.SubElement(workspace, "Properties")
    build.prop(workspace, "string", "Name", "Workspace")
    items = {}
    def vector(item, name, values, kind="Vector3"):
        element = ET.SubElement(item.find("Properties"), kind, name=name)
        for axis, value in zip(("X","Y","Z"), values):
            ET.SubElement(element, axis).text = str(value)
    def frame(item, values):
        element = ET.SubElement(item.find("Properties"), "CoordinateFrame", name="CFrame")
        for key, value in zip(("X","Y","Z","R00","R01","R02","R10","R11","R12","R20","R21","R22"),values):
            ET.SubElement(element,key).text=str(value)
    allowed={"Model","Folder","Part","MeshPart","VehicleSeat","Attachment","ModuleScript"}
    for row in rows:
        assert row["class"] in allowed, f"Unexpected class: {row['class']}"
        item=ET.SubElement(items.get(row["parent"],workspace),"Item",{"class":row["class"],"referent":f"Art{row['id']}"})
        ET.SubElement(item,"Properties")
        items[row["id"]]=item
        build.prop(item,"string","Name",row["name"])
        if "cf" in row:
            frame(item,row["cf"])
        if "size" in row:
            vector(item,"size",row["size"])
            color=ET.SubElement(item.find("Properties"),"Color3",name="Color")
            for channel,value in zip(("R","G","B"),row["color"]):
                ET.SubElement(color,channel).text=str(value)
            build.prop(item,"float","Transparency",str(row["transparency"]))
            build.prop(item,"token","Material",str(row["material"]))
            build.prop(item,"bool","Anchored","true")
            build.prop(item,"bool","CanCollide",str(row["collide"]).lower())
        if "shape" in row:
            build.prop(item,"token","shape",str(row["shape"]))
        if "mesh" in row:
            if "meshSize" in row:
                vector(item,"InitialSize",row["meshSize"])
            for name,key in (("MeshId","mesh"),("TextureID","texture")):
                content=ET.SubElement(item.find("Properties"),"Content",name=name)
                ET.SubElement(content,"url" if row[key] else "null").text=row[key] or None
        if "primary" in row:
            build.prop(item,"Ref","PrimaryPart",f"Art{row['primary']}")
        if "source" in row:
            assert row["name"]=="Tune", "Only authored Tune module allowed"
            build.prop(item,"ProtectedString","Source",row["source"])
    service=next(x for x in tree.findall("Item") if x.attrib["class"]=="ServerScriptService")
    script=ET.SubElement(service,"Item",{"class":"Script","referent":"LocalArtRegistration"})
    ET.SubElement(script,"Properties")
    build.prop(script,"string","Name","ImportedCarRegistration")
    build.prop(script,"ProtectedString","Source",'local m=workspace:WaitForChild("AXZF_ImportedCar") m.Chassis.CustomPhysicalProperties=PhysicalProperties.new(1.2,.3,0,100,100) m:SetAttribute("SourceAsset","14215126016") game:GetService("CollectionService"):AddTag(m,"AXZFVehicle")')
    ET.indent(tree,space="  ")
    path=ROOT/"build/Studio-With-ImportedCar.rbxlx"
    path.write_bytes(ET.tostring(tree,encoding="utf-8",xml_declaration=True))
    print(f"Local scene written ({len(rows)} geometry nodes). Third-party art remains excluded from Git.")


if __name__=="__main__":
    export()
