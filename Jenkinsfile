pipeline {
    agent any
    tools {
        maven "Maven"
    }
    
    parameters {
        booleanParam(name: "dryrun", defaultValue: false, description: "Тестовый запуск")
        booleanParam(name: "cleanUp", defaultValue: true, description: "Очистити воркспейс")
        booleanParam(name: "skipTest", defaultValue: false, description: "Skip testing part")
    }
    
    stages {
        
        stage('DryRun') {
            when {
                expression { params.dryrun }
            }
            steps {
                echo "THIS IS DRYRUN!"
            }
        }
        
        stage('CleanUp') {
            when {
                expression { params.cleanUp }
            }
            steps {
                echo "RUN CLEANUP FOR WS"
                cleanWs()
            }
        }
        
        stage('Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/Wamgleb/Test-CICD-2']])
            }
        }
        
        stage('Run JUnit Test') {
            when {
                expression { !params.skipTest }
            }
            parallel {
                stage('Run backend') {
                    steps {
                        echo "Start testing"
                        dir('msi') {
                            sh "mvn test > junit_test_maven_msi_result.txt"
                            sh "sleep 20"
                        }
                    }
                }
                
                stage('Run for frontend') {
                    steps {
                        echo "Start testing"
                        dir('msi-ui/trucks') {
                            sh "mvn test > junit_test_maven_msi_ui_result.txt"
                            sh "sleep 20"
                        }
                    }
                }
            }
        }
        
        stage('Run Integration Test') {
            when {
                expression { !params.skipTest }
            }
            parallel {
                stage('Run integration test for backend') {
                    steps {
                        dir('msi') {
                            echo "Run Integration Test"
                            sh "mvn clean integration-test > integration_test_msi_log.txt"
                            sh "sleep 20"
                        }
                    }
                }
                
                stage('Run integration test for frontend') {
                    steps {
                        dir('msi-ui/trucks') {
                            echo "Run Integration Test"
                            sh "mvn clean integration-test > integration_test_msi_ui_log.txt"
                            sh "sleep 20"
                        }
                    }
                }
            }
        }
        
        stage('Run Performance Test with JMeter') {
            when {
                expression { !params.skipTest }
            }
            steps {
                dir('msi') {
                    echo "Run Performance Test with JMeter"
                    sh "mvn clean verify > performance_test_log.txt"
                    sh "sleep 20"
                }
            }
        }
        
        stage('Build Maven project') {
            steps {
                dir('msi') {
                    sh "mvn clean install > build_result_jar_log.txt"
                }
                dir('msi-ui/trucks') {
                    sh "mvn clean package > build_result_war_log.txt"
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: "msi/build_result_jar_log.txt", allowEmptyArchive: true
                    archiveArtifacts artifacts: "msi-ui/trucks/build_result_war_log.txt", allowEmptyArchive: true
                }
                success {
                    echo "Succses"
                    archiveArtifacts artifacts: "msi/target/*.jar", allowEmptyArchive: true
                    archiveArtifacts artifacts: "msi-ui/trucks/target/*.jar", allowEmptyArchive: true
                }
                failure {
                    echo "Fail"
                }
            }
        }
        
        stage('Delivery Maven project') {
            steps {
                dir('msi') {
                    sh './script/deliver.sh > deliver_log.txt'
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh "docker build -t wam77/diplom:latest ."
            }
        }
        
        stage('Push Image to DockerHub') {
            steps {
                withCredentials([string(credentialsId: 'wam77', variable: 'dockerHub')]) {
                    sh "docker login -u wam77 -p ${dockerHub}"
                    sh "docker push wam77/diplom:latest"
                }
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: "msi/*.txt", allowEmptyArchive: true
            archiveArtifacts artifacts: "msi-ui/trucks/*.txt", allowEmptyArchive: true
        }
        cleanup {
            cleanWs()
        }
    }
}