package org.onap.pnfsimulator;

public class PnfSimConfig {
    private String urlves;
    private String urlftps;
    private String urlsftp;
    private String ippnfsim;
    private String defaultfileserver;

    public String getDefaultfileserver() {
        return defaultfileserver;
    }

    public void setDefaultfileserver(String defaultfileserver) {
        this.defaultfileserver = defaultfileserver;
    }


    public String getUrlves() {
        return urlves;
    }

    public void setUrlves(String urlves) {
        this.urlves = urlves;
    }

    public String getUrlftps() {
        return urlftps;
    }

    public void setUrlftps(String urlftps) {
        this.urlftps = urlftps;
    }

    public String getUrlsftp() {
        return urlsftp;
    }

    public void setUrlsftp(String urlsftp) {
        this.urlsftp = urlsftp;
    }

    public void setIppnfsim(String ippnfsim) {
        this.ippnfsim = ippnfsim;
    }

    public String getIppnfsim() {
        return ippnfsim;
    }

    @Override
    public String toString() {
        return "PnfSimConfig [vesip=" + urlves + ", urlftps=" + urlftps + ", ippnfsim=" + ippnfsim + ", urlsftp="
                + urlsftp + "]";
    }



}
