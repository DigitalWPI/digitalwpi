# Migrate objects from DigitalWPI v1 to v2

The instructions here focus on the code to be run as a part of the migration.
When we have access to files, and are ready to import filesets, we will add instructions here on copying the files from DigitalWPi v1 to V2.

These instructions are for

*  [feature/upgrade-hyrax-v5](https://github.com/DigitalWPI/digitalwpi/tree/feature/upgrade-hyrax-v5) for DigitalWPI v2
* commit [a14c652](https://github.com/DigitalWPI/digitalwpi/commit/a14c652d853e75516b214f3e8d54eea184c1ac5e)  as a part of DigitalWPI v1

## Export users, collections, works and filesets

To run the export,

1. Deploy the dev branch to DigitalWPI prod
   * If not deploying the changes, copy the following files to DigitalWPI prod and restart apache (web and workers)

     `hyrax/app/services/export_metadata_service.rb`

     `hyrax/app/jobs/export_metadata_job.rb`
2. Start a rails console in the web container and start the export job
   * Start the rails console

     ```
     docker exec -it digitalwpi_web_1 /bin/bash
     rails c
     ```
   * Start the export job in the rails console

     ```
     ExportMetadataJob.perform_later(update=true)
     ```
     * We can pass 3 arguments to `ExportMetadataJob`
       * `update`= `true`|`false` (default true)
       * `models_to_export`=`%w[Collection Etd GenericWork StudentWork FileSet User Role Id]`
         * This can be one or more of the 7 models listed above and Id, to map all Ids to uuid. The default is all of them.
         * It would be good to map Ids, after all of the collections, works (`Etd`, `GenericWork` and `StudentWork`) and filesets are exported.
         * In order for FileSet export to map the parent work correctly, we would need to export all works and filesets together
       * `base_dir` = `"/tmp/metadata_export"`
         * The default value for the base_dir is `/tmp/metadata_export`. This can be set to any other file path the digitalWPI web service has access to write to. 
       
       For example, we could also say
       
       ```
       ExportMetadataJob.perform_later(update=false, models_to_export=%w[Etd GenericWork StudentWork FileSet], base_dir="data/metadata_export")
       ```
   * Exit from the container
   
     ```
     exit
     ```

* Monitoring the export job
  * The job should be visible in sidekiq (https://digital.wpi.edu/sidekiq/busy)
  * The logs of the worker will output the current state of the job

    ```
    tail -f /var/log/digitalwpi/current/logs/production.log
    ```

  The exported files are stored in the `/tmp/metadata_export`

## Copy the exported files to DigitalWPI V2

1. Copy the files exported from DigitalWPI v1
   * Copy the files from `/tmp/metadata_export` directory in DigitalWPI v1 to DigitalWPI v2 `/shared/uploads/`
     * You can rename the directory `metadata_export` as needed (for example `export_v1`)
   * The export metadata files are visible in the respective docker host machines at `/var/lib/docker/volumes/digitalwpi_uploads/_data`

* The `/shared/uploads` docker volume is visible in the docker host machine at `/var/lib/docker/volumes/digitalwpi_uploads/_data` 

## Import objects to DigitalWPI v2

### Steps to perform before starting an import

1. Copy the `DEVISE_SECRET_KEY` from DigitalWPI v1 to the .env file in DigitalWPI v2

2. Stop DigitalWPI V2 docker containers.

3. Delete all the docker volumes
   
4. Deploy the latest code in [feature/upgrade-hyrax-v5](https://github.com/DigitalWPI/digitalwpi/tree/feature/upgrade-hyrax-v5) to DigitalWPI v2 test machine

5. Copy the export data as described in the section _Copy the exported files to DigitalWPI V2_.

### Import DigitalWPI V1 content to DigitalWPI v2

* The import starts with executing the `ImportAllObjectsJob`. 
   * We can pass 3 arguments to `ImportAllObjectsJob`
      * `base_dir` = '/shared/uploads/metadata/'
      * `models_to_import = %w[Role User Collection CollectionMember Etd GenericWork StudentWork FileSet]`
         * This can be one or more of the models listed above. The default is all.

      * `fileset_models_to_ingest = %w[Collection Etd GenericWork StudentWork]`
         * This can be one or more of the 4 models listed above.

* The import needs to be in the following order - Role, User, Collection, CollectionMember, Works (Etd, GenericWork or StudentWork), FileSet, Work members

* The import jobs are scheduled and run by Sidekiq.
   * After users have been imported (the url is only available to a user with role admin), the progress of an import job can be monitored from the url `/sidekiq/busy`

* To make testing better, we recommend splitting the import and run it multiple times - i.e. Role, User, Collection, CollectionMember, Etd, FileSets associated with  Etd (when ready), GenericWork, Filesets associated with GenericWork, StudentWork and Filesets associated with StudentWork. 
* Similarly, we can also import each of the work types (StudentWork /  GenericWork / Etd) and their associated filesets over a few batches
* We have scripts to verify the status of the import after each run, so we can fix any errors  before proceeding to the next step


Start a rails console in the web container
```
docker exec -it digitalwpi_web_1 /bin/bash
rails c
```

Define the base directory and include the `CheckImportHelper` module before we run the import jobs

```
include CheckImportHelper
base_dir = "/shared/uploads/metadata_export/"
```

1. **Import roles**

   ```
   ImportAllObjectsJob.perform_later(base_dir, models_to_import=%w[Role])
   ```

   **Verify all roles have been imported**

   Once the import of roles has completed, you can verify the status of the import

   ```
   ans1 = check_roles(base_dir)
   ```

   **Create missing roles** (if needed)

   If there were any missing roles, we could run the code to create missing roles

   ```
   ans_a = create_missing_roles(base_dir)
   ```

2. **Import users**

   ```
   ImportAllObjectsJob.perform_later(base_dir, models_to_import=%w[User])
   ```

   **Verify all users have been imported**

   Once the import of users has completed, you can verify all users have been created

   ```
   ans2 = check_users(base_dir)
   ```

   **Create missing users** (if needed)

   If there were any missing users, we could run the code to create missing users

   ```
   ans_b = create_missing_users(base_dir)
   ```

   **Verify all users are assigned to the correct role**

   As a next step, we can also verify if all users have been assigned to their respective roles

   ```
   ans3 = check_users_in_roles(base_dir)
   ```

   **Assign missing users to roles** (if needed)

   If there were any missing users from roles, we could run the code to assign missing users to roles 

   ```
   ans_c = fix_users_in_roles(base_dir)
   ```

3. **Import collections**

   ```
   ImportAllObjectsJob.perform_later(base_dir, models_to_import=%w[Collection])
   ```

   **Verify all collections have been imported**

   Once the import of collections has completed, you can verify the status of the import of collections

   ```
   ans4a = check_collections(base_dir)
   ```

   You will notice that the collections do not have the parent assigned

   **Add collection membership**

   ```
   ImportAllObjectsJob.perform_later(base_dir, models_to_import=%w[CollectionMember])
   ```

   **Verify all collections have been imported again**

   Once the import of collection members has completed, you can verify the status of the import of collections, along with their membership

   ```
   ans4b = check_collections(base_dir)
   ```

4. **Import ETDs**

   ```
   ImportAllObjectsJob.perform_later(base_dir, models_to_import=%w[Etd])
   ```

   **Verify all ETDs have been imported**

   Once the import of ETDs has completed, you can verify the status of the import of datasets

   ```
   ans5 = check_work(base_dir, 'Etd')
   ```

5. **Import GenericWorks**

   ```
   ImportAllObjectsJob.perform_later(base_dir, models_to_import=%w[GenericWork])
   ```

   **Verify all GenericWorks have been imported**

   Once the import of GenericWorks has completed, you can verify the status of the import of datasets

   ```
   ans6 = check_work(base_dir, 'GenericWork')
   ```

6. **Import StudentWorks**

   ```
   ImportAllObjectsJob.perform_later(base_dir, models_to_import=%w[StudentWork])
   ```

   **Verify all StudentWorks have been imported**

   Once the import of StudentWorks has completed, you can verify the status of the import of datasets

   ```
   ans7 = check_work(base_dir, 'StudentWork')
   ```

Exit from the container

```
exit
```

