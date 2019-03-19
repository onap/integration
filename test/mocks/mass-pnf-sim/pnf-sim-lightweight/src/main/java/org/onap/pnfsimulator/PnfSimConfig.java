package org.onap.pnfsimulator;

public class PnfSimConfig {
    private String vesip;
    private String ipftps;
    private String ipsftp;
    private String ippnfsim;

    public String getVesip() {
        return vesip;
    }

    public void setVesip(String vesip) {
        this.vesip = vesip;
    }

    public String getIpftps() {
        return ipftps;
    }

    public void setIpftps(String ipftps) {
        this.ipftps = ipftps;
    }

    public String getIpsftp() {
        return ipsftp;
    }

    public void setIpsftp(String ipsftp) {
        this.ipsftp = ipsftp;
    }

    public void setIppnfsim(String ippnfsim) {
        this.ippnfsim = ippnfsim;
    }

    @Override
    public String toString() {
        return "PnfSimConfig [vesip=" + vesip + ", ipftps=" + ipftps + ", ippnfsim=" + ippnfsim + ", ipsftp=" + ipsftp
                + "]";
    }

    public String getIppnfsim() {
        return ippnfsim;
    }



}
