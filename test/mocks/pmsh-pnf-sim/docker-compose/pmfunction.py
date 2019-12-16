import xml.etree.ElementTree as ET
import os
import gzip
import shutil

def generatexml(jobId,timestemp):
        script_dir = os.path.dirname(__file__)
        pm_rel_file_path = "sftp/"
        pm_location = os.path.join(script_dir,pm_rel_file_path)
        ET.register_namespace('', "http://www.3gpp.org/ftp/specs/archive/32_series/32.435#measCollec")
        tree = ET.parse(pm_location+"A.xml")
        root = tree.getroot()
        attrib = {}
        measInfo = ET.SubElement(root[1],'measInfo',attrib)
        attrib = { 'jobId': jobId}
        ET.SubElement(measInfo,'job', attrib)
        ET.SubElement(measInfo,'granPeriod', {'duration': 'PT900S', 'endTime': '2000-03-01T14:14:30+02:00'})
        ET.SubElement(measInfo,'repPeriod', {'duration': 'PT1800S'})
        meastype = ET.SubElement(measInfo,'measType', {'p': '1'})
        meastype.text = "attTCHSeizures"
        meastype = ET.SubElement(measInfo,'measType', {'p': '2'})
        meastype.text = "succTCHSeizures"
        measValue = ET.SubElement(measInfo,'measValue', {'measObjLdn': 'RncFunction=RF-1,UtranCell=Gbg-997'})
        value = ET.SubElement(measValue,'r', {'p': '1'})
        value.text = "900"
        value = ET.SubElement(measValue,'r', {'p': '2'})
        value.text = "400"
        tree.write(pm_location+"A.xml",encoding="utf-8", xml_declaration=True)
        shutil.copy(pm_location+"A.xml",pm_location+"A{}.xml".format(timestemp))

        with open(pm_location+"A{}.xml".format(timestemp), 'rb') as f_in:
                with gzip.open(pm_location+"A{}.xml.gz".format(timestemp), 'wb') as f_out:
                        shutil.copyfileobj(f_in, f_out)
        os.remove(pm_location+"A{}.xml".format(timestemp))