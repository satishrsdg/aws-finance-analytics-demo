
from pathlib import Path
from config import DICT_SQL;

def create_database(resource):
    return 'CREATE DATABASE ' + resource + ';'

def create_table(resource):
    ddl_cmd = Path(DICT_SQL[resource]).read_text()
    return ddl_cmd
