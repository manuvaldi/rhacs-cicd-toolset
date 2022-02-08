# rhacs-cicd-toolset

Toolset to manage CI/CD in RHACS

## acs-cluster-labels.sh

```
usage: acs-cluster-label.sh <action> <option1> <option2>
       acs-cluster-label.sh list
       acs-cluster-label.sh showlabels
       acs-cluster-label.sh showlabels <clusterid>
       acs-cluster-label.sh setlabel <clusterid> <label>
         example:  acs-cluster-label.sh setlabel 6e6b4fd2-aaaa-bbbb-cccc-e311da7caeaf environment=dev
       acs-cluster-label.sh unsetlabel <clusterid> <label or key>
         example1:  acs-cluster-label.sh unsetlabel 6e6b4fd2-aaaa-bbbb-cccc-e311da7caeaf environment=dev
         example2:  acs-cluster-label.sh unsetlabel 6e6b4fd2-aaaa-bbbb-cccc-e311da7caeaf environment
```
